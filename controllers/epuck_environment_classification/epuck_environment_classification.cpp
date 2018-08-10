/* Include the controller definit*io*itn */
#include "epuck_environment_classification.h"

#define ALPHA_CHANNEL 0
#define COLOR_STRENGHT 255
#define N_COL 3

#include <iostream>
#include <algorithm>
#include <sstream>
#include <unistd.h>
#include <map>
#include <thread>


/****************************************/
/****************************************/

using namespace std;

/* Convert a number to a string */
template <typename T> std::string NumberToString ( T Number )
{
  std::ostringstream ss;
  ss << Number;
  return ss.str();
}

EPuck_Environment_Classification::EPuck_Environment_Classification() :
  m_pcWheels (NULL),
  m_fWheelVelocity (10.0f),
  m_pcRABA (NULL),
  m_pcRABS (NULL),
  m_cAlpha (10.0f),
  m_fDelta(0.5f),
  m_pcProximity(NULL),
  m_cGoStraightAngleRange(-ToRadians(m_cAlpha),
			  ToRadians(m_cAlpha)) {}

EPuck_Environment_Classification::CollectedData::CollectedData() :
  count (0) {}

EPuck_Environment_Classification::Opinion::Opinion() :
  countedCellOfActualOpinion (0)  {}

EPuck_Environment_Classification::Movement::Movement() :
  walkTime (3),
  actualDirection (0){}


/************************************************* INIT ********************************************************/
/***************************************************************************************************************/
void EPuck_Environment_Classification::SimulationState::Init(TConfigurationNode& t_node) {

  try{
    /* Getting sigma, G value and the decision rule to follow */
    GetNodeAttribute(t_node, "g", g);
    GetNodeAttribute(t_node, "sigma", sigma);
    GetNodeAttribute(t_node, "lamda", LAMDA);
    GetNodeAttribute(t_node, "turn", turn);
    GetNodeAttribute(t_node, "decision_rule", decision_rule);
    GetNodeAttribute(t_node, "exitFlag", exitFlag);
    GetNodeAttribute(t_node, "percent_white", percentRed);
    GetNodeAttribute(t_node, "percent_black", percentBlue);
    GetNodeAttribute(t_node, "num_pack_saved", numPackSaved);
    GetNodeAttribute(t_node, "base_dir", baseDir);
    GetNodeAttribute(t_node, "base_port", basePort);
    GetNodeAttribute(t_node, "profiling", profiling);
  }
  catch(CARGoSException& ex) {
    THROW_ARGOSEXCEPTION_NESTED("Error initializing controller state parameters.", ex);
  }
}

void EPuck_Environment_Classification::Init(TConfigurationNode& t_node) {

  eventTrials = 0;
  receivedDecision = true;
  consensusReached = false;
  
  /* Initialize the actuators (and sensors) and the initial velocity as straight walking*/
  m_pcWheels = GetActuator<CCI_EPuckWheelsActuator>("epuck_wheels");
  m_pcProximity = GetSensor <CCI_EPuckProximitySensor>("epuck_proximity");
  m_pcLEDs = GetActuator<CCI_LEDsActuator>("leds");
  m_pcRABA = GetActuator<CCI_EPuckRangeAndBearingActuator>("epuck_range_and_bearing");
  m_pcRABS = GetSensor  <CCI_EPuckRangeAndBearingSensor>("epuck_range_and_bearing");
  m_pcRNG = CRandom::CreateRNG("argos");
  m_cGoStraightAngleRange.Set(-ToRadians(m_cAlpha), ToRadians(m_cAlpha));
  GetNodeAttributeOrDefault(t_node, "velocity", m_fWheelVelocity, m_fWheelVelocity);
  simulationParams.Init(GetNode(t_node, "simulation_parameters"));

  simulationParams.g = simulationParams.g * 10;
  simulationParams.sigma = simulationParams.sigma * 10;

  /* Colours read from robots could be changed and added here! AGGIUNGERECOLORI */
  red.Set(COLOR_STRENGHT,0,0,ALPHA_CHANNEL);      // Change alphachannel has not effect visively, but changing COLOR_STRENGHT could make
  green.Set(0,COLOR_STRENGHT,0,ALPHA_CHANNEL);    // cells more or less bright
  blue.Set(0,0,COLOR_STRENGHT,ALPHA_CHANNEL);

  /* Assign the initial state of the robots: all in exploration state*/
  m_sStateData.State = SStateData::STATE_EXPLORING;

  std::string m_strOutput;
  m_strOutput = GetId();

  /* INITIAL QUALITY: has to be estimated in the first exploration state */
  opinion.quality = 0;
  
  if(simulationParams.percentRed < simulationParams.percentBlue)
    simulationParams.percentRed = simulationParams.percentBlue;
  simulationParams.percentRed = simulationParams.percentRed / 100;

  voteInformation = "";
    
}


/************************************************* CONTROL STEP ************************************************/
/***************************************************************************************************************/
void EPuck_Environment_Classification::ControlStep() {

  int robotId = Id2Int(GetId());
  
  /* Turn leds according with actualOpinion */
  TurnLeds();
	
  /* Move robots following randomWalk */
  Move();

  /* Two different behaviours, depending on if they are diffusing or exploring */
  switch(m_sStateData.State) {
    
  case SStateData::STATE_EXPLORING: {
    Explore();    
    break;
  }

  case SStateData::STATE_DIFFUSING: {  
    Diffusing();
    break;
  }
    
  }
  
  RandomWalk();

  /**** OBSTACLE AVOIDANCE ****/

  /* Get readings from proximity sensor and sum them together */
  const CCI_EPuckProximitySensor::TReadings& tProxReads = m_pcProximity->GetReadings();
  CVector2 cAccumulator;
  for(size_t i = 0; i < tProxReads.size(); ++i) {
    cAccumulator += CVector2(tProxReads[i].Value, tProxReads[i].Angle);
  }
  if(tProxReads.size()>0)
    cAccumulator /= tProxReads.size();
  /* If the angle of the vector is not small enough or the closest obstacle is not far enough curve a little */
  CRadians cAngle = cAccumulator.Angle();
  if(!(m_cGoStraightAngleRange.WithinMinBoundIncludedMaxBoundIncluded(cAngle) && cAccumulator.Length() < m_fDelta )) {
    /* Turn, depending on the sign of the angle */
    if(cAngle.GetValue() > 0.0f) {
      m_pcWheels->SetLinearVelocity( m_fWheelVelocity, 0.0f);
    }
    else {
      m_pcWheels->SetLinearVelocity(0.0f, m_fWheelVelocity);
    }
  }  
}

/************************************************** RANDOM WALK ************************************************/
/***************************************************************************************************************/
void EPuck_Environment_Classification::RandomWalk() {


  /* walkTime represents the number of clock cycles (random number) of walk in a random direction*/
  if ( movement.walkTime == 0 )                            // Is the walkTime in that direction finished? ->
    { 				                       // -> YES: change direction//
      
      if ( movement.actualDirection == 0 )                  // If robot was going straight then turn standing in ->
	// -> a position for an uniformly distribuited time //
	{
	  CRange<Real> zeroOne(0.0,1.0);
	  Real p = m_pcRNG->Uniform(zeroOne);
	  p = p*simulationParams.turn;
	  Real dir = m_pcRNG->Uniform(CRange<Real>(-1.0,1.0));
	  if ( dir > 0 )
	    movement.actualDirection = 1;
	  else
	    movement.actualDirection = 2;
	  movement.walkTime = Floor(p);
	}
      
      else 						// The robot was turning, time to go straight for ->
	// -> an exponential period of time //
	{
	  movement.walkTime = Ceil(m_pcRNG->Exponential((Real)simulationParams.LAMDA)*4); // Exponential random generator. *50 is a scale factor for the time
	  movement.actualDirection = 0;
	}
    }
  else {							// NO: The period of time is not finished, decrement the ->
    // -> walkTime and keep the direction //
    movement.walkTime--;
  }
}

/************************************************* EXPLORING STATE *********************************************/
/***************************************************************************************************************/
void EPuck_Environment_Classification::Explore() {

  int robotId = Id2Int(GetId());
  
  /* remainingExplorationTime it's the variable decremented each control step. 
   * This variable represents the time that a robot must still spend in exploration state.
   * If this variable it's greater than zero, then it must be decremented and the robot should 
   * do exploration's stuffs (Update counters figuring out in which cell he is. It's done in loop function */
  if(m_sStateData.remainingExplorationTime > 0){		
    m_sStateData.remainingExplorationTime--;
  }

  /* If its time to change state, then the robot has to reset his own variables:
   * - Assign a new random exponential time: remainingExplorationTime and explorDurationTime (used to
   *   keep trace of the exploration times, just for statistic aims);
   * - Calculate the quality of the opinion, basing on the sensed datas (Number of counted cells of actual
   *   opinion / Number of total counted cells);
   * - Reset counting variables (countedCellOfActualOpinion and count [total number of cells counted]);
   * - Change state: Exploration->Diffusing;
   * - Generate a new Diffusing time (same as exploring, but used for Diffusing state and calculated with
   *   different params for the random variable;
   */
  else{


    /* If this robot is a Byzantine robot, it always uses quality estimate 1.0 */
    if (byzantineStyle == 1) {
      opinion.quality = 1.0;

      /* If this robot is a Byzantine robot, its quality estimate is
	 drawn from a value between 0.0 and 1.0 */
    } else if (byzantineStyle == 2) {
      opinion.quality = m_pcRNG->Uniform(CRange<Real>(0.0,1.0));
      
    } else {
      opinion.quality = (Real)((Real)(opinion.countedCellOfActualOpinion)/(Real)(collectedData.count));    
    }

    opinion.countedCellOfActualOpinion = 0;
    collectedData.count = 0;
    m_sStateData.State = SStateData::STATE_DIFFUSING;

    uint opinionInt = (uint) (opinion.quality * 10000000); // Convert opinion quality to a value between 0 and 10000000


    ostringstream voteAndIdStream;
    voteAndIdStream << opinionInt << "," << robotId;
    voteInformation = voteAndIdStream.str();
          
    string args[0] = {};
    smartContractInterfaceStringBg(robotId, interface, contractAddress, "vote", args, 0, opinionInt, nodeInt, simulationParams.blockchainPath);
    
    /* Assigning a new exploration and time, for the next exploration state */
    
    //    m_sStateData.remainingExplorationTime = Ceil(m_pcRNG->Exponential((Real)simulationParams.sigma));
    m_sStateData.remainingExplorationTime = 300;
    m_sStateData.explorDurationTime = m_sStateData.remainingExplorationTime;
  }  
}

/************************************************* DIFFUSING STATE *********************************************/
/***************************************************************************************************************/

void EPuck_Environment_Classification::Diffusing() {

  /* Query consensous reached */
  if (!threadCurrentlyRunning){
    threadCurrentlyRunning = true;
    thread t1(&EPuck_Environment_Classification::WaitForDecision, this);
    t1.detach();
  }
  
  /* Change to EXPLORING state and choose another opinion with decision rules */
  m_sStateData.State = SStateData::STATE_EXPLORING;
    
}


/************************************************* MOVEMENT ****************************************************/
/***************************************************************************************************************/
/* Implement the moviment leaded by the random walk (see loop_function) */
void EPuck_Environment_Classification::Move(){
  if(movement.actualDirection == 0) // Go straight
    m_pcWheels->SetLinearVelocity(m_fWheelVelocity,  m_fWheelVelocity);
  else
    if(movement.actualDirection == 1) // Turn right
      m_pcWheels->SetLinearVelocity(m_fWheelVelocity,  -m_fWheelVelocity);
    else
      if(movement.actualDirection == 2) // Turn left
	m_pcWheels->SetLinearVelocity(-m_fWheelVelocity,  m_fWheelVelocity);
}

/************************************************* TURNING LEDS ON *********************************************/
/***************************************************************************************************************
0 = BLACK/EX-RED;
1 = GREEN; 
2 = WHITE/EX-BLUE
AGGIUNGERECOLORI 
*/
void EPuck_Environment_Classification::TurnLeds(){

  switch(opinion.actualOpinion) {

  case 1: {
    opinion.actualOpCol = CColor::WHITE;
    m_pcLEDs->SetAllColors(CColor::WHITE);
    break;
  }
  case 2: {
    opinion.actualOpCol = CColor::BLACK;
    m_pcLEDs->SetAllColors(CColor::BLACK);
    break;
  }
  case 3: {
    opinion.actualOpCol = CColor::GREEN;
    m_pcLEDs->SetAllColors(CColor::GREEN);
    break;
  }
  }
}

void EPuck_Environment_Classification::fromLoopFunctionResPrepare(){

  opinion.countedCellOfActualOpinion = 0;
  opinion.quality = 0;
  collectedData.count = 0;

  CCI_EPuckRangeAndBearingActuator::TData toSend;
  toSend[0] = Id2Int(GetId());
  m_pcRABA->SetData(toSend);
  m_pcRABS->ClearPackets();
  TurnLeds();

  /* Assign the initial state of the robots: all in exploration state*/
  m_sStateData.State = SStateData::STATE_EXPLORING;

  /* Assign the exploration time (random generated) */
  m_sStateData.remainingExplorationTime = (m_pcRNG->Exponential((Real)simulationParams.sigma));
  m_sStateData.explorDurationTime = m_sStateData.remainingExplorationTime;

  int robotId = Id2Int(GetId());

  beginning = true;
  
  /* Ethereum */
  nodeInt = robotIdToNode[robotId];       
  interface = readStringFromFile(simulationParams.baseDir + simulationParams.interfacePath);
    
  ostringstream genesisPathStream;
  genesisPathStream << "~/genesis/genesis" << simulationParams.basePort << ".json";
  string genesisPath = genesisPathStream.str();
  geth_init(robotId, nodeInt, simulationParams.basePort, simulationParams.blockchainPath, genesisPath);
  start_geth(robotId, nodeInt, simulationParams.basePort, simulationParams.blockchainPath);
  createAccount(robotId, nodeInt, simulationParams.basePort, simulationParams.blockchainPath);
  coinbaseAddresses[robotId] = getCoinbase(robotId, nodeInt, simulationParams.basePort, simulationParams.blockchainPath);
  address = coinbaseAddresses[robotId];          
  prepare_for_new_genesis(robotId, nodeInt, simulationParams.basePort, simulationParams.blockchainPath);      
}

void EPuck_Environment_Classification::fromLoopFunctionResStart(){

  if (!simulationParams.useClassicalApproach) {
    int robotId = Id2Int(GetId());
  
    ostringstream genesisPathStream;
    genesisPathStream << "~/genesis/genesis" << simulationParams.basePort << ".json";
    string genesisPath = genesisPathStream.str();
        
    geth_init(robotId, nodeInt, simulationParams.basePort, simulationParams.blockchainPath, genesisPath);
    start_geth(robotId, nodeInt, simulationParams.basePort, simulationParams.blockchainPath);
    enodes[robotId] = get_enode(robotId, nodeInt, simulationParams.basePort, simulationParams.blockchainPath);
    enode = enodes[robotId];
    unlockAccount(robotId, "test", nodeInt, simulationParams.basePort, simulationParams.blockchainPath);
  }
}

/****************************************/
/****************************************/


REGISTER_CONTROLLER(EPuck_Environment_Classification, "epuck_environment_classification_controller")
