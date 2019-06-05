/* Include the controller definition */
#include "helpers.h"
#include "epuck_environment_classification.h"


#define ALPHA_CHANNEL 0
#define COLOR_STRENGTH 255
#define N_COL 3

#include <iostream>
#include <algorithm>
#include <sstream>
#include <unistd.h>
#include <map>
#include <thread>
#include <algorithm>


/****************************************/
/****************************************/

using namespace std;

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

EPuck_Environment_Classification::MyPacket::MyPacket() :
  value (0) {}


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
    GetNodeAttribute(t_node, "lambda", LAMBDA);
    GetNodeAttribute(t_node, "turn", turn);
    GetNodeAttribute(t_node, "decision_rule", decisionRule);
    GetNodeAttribute(t_node, "exitFlag", exitFlag);
    GetNodeAttribute(t_node, "percent_white", percentRed);
    GetNodeAttribute(t_node, "percent_black", percentBlue);
    GetNodeAttribute(t_node, "num_pack_saved", numPackSaved);
    GetNodeAttribute(t_node, "profiling", profiling);
    GetNodeAttribute(t_node, "max_stored_opinions", maxStoredOpinions);
    GetNodeAttribute(t_node, "exploration_time", explorationTime);
  }
  catch(CARGoSException& ex) {
    THROW_ARGOSEXCEPTION_NESTED("Error initializing controller state parameters.", ex);
  }
}

void EPuck_Environment_Classification::Init(TConfigurationNode& t_node) {

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

  simulationParams.g = simulationParams.g;
  simulationParams.sigma = simulationParams.sigma;

  /* Colours read from robots could be changed and added here! AGGIUNGERECOLORI */
  red.Set(COLOR_STRENGTH,0,0,ALPHA_CHANNEL)
    ;      // Change alphachannel has not effect visively, but changing COLOR_STRENGTH could make
  green.Set(0,COLOR_STRENGTH,0,ALPHA_CHANNEL);    // cells more or less bright
  blue.Set(0,0,COLOR_STRENGTH,ALPHA_CHANNEL);

  /* Assign the initial state of the robots: all in exploration state*/
  m_sStateData.State = SStateData::STATE_EXPLORING;

  std::string m_strOutput;
  m_strOutput = GetId();

  // Initial quality; the actual quality has to be estimated in the
  // exploration states
  opinion.quality = 0;
  
  if(simulationParams.percentRed < simulationParams.percentBlue)
    simulationParams.percentRed = simulationParams.percentBlue;
  simulationParams.percentRed = simulationParams.percentRed / 100;

}

/************************************************* CONTROL STEP ************************************************/
/***************************************************************************************************************/
void EPuck_Environment_Classification::ControlStep() {

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
	  movement.walkTime = Ceil(m_pcRNG->Exponential((Real)simulationParams.LAMBDA)*4); // Exponential random generator. *50 is a scale factor for the time
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
  
  // If the robot is a jammer, if performs its action in every time step
  if (byzantineStyle == Jamming) {
    CCI_EPuckRangeAndBearingActuator::TData toSend;
    toSend[0] = robotId;
    toSend[1] = 0;
    toSend[2] = 0;
    toSend[3] = 1;
    m_pcRABA->SetData(toSend);
  }
  
  explorationCounter++;
  
  if(m_sStateData.remainingExplorationTime > 0){		
   
    m_sStateData.remainingExplorationTime--;

    
    /* Send estimates to other robots  */
    CCI_EPuckRangeAndBearingActuator::TData toSend;
    toSend[0] = Id2Int(GetId());
    toSend[3] = 0;
    double totalQualityRounded = roundf(totalQuality * 100);
    cout << "totalQualityRounded = " << totalQualityRounded << endl;
    
    if (numExplorationPhase > 2) {
      toSend[1] = (int) (totalQualityRounded);
      toSend[2] = 1;
    }

    // If this robot is a Byzantine robot, it always uses quality estimate 1.0
    switch (byzantineStyle) {
      case AlwaysZero:
      case SybilAlwaysZero:
	toSend[1] = 0;
        break;

      case AlwaysOne:
      case SybilAlwaysOne:
	toSend[1] = 100;	
        break;
	
      case RandomZeroOne: {
      case SybilRandomZeroOne:
        CRange<Real> zeroOne(0.0, 1.0);
        Real p = m_pcRNG->Uniform(zeroOne);
        if (p > 0.5) {
	  toSend[1] = 0;	  
        } else {
	  toSend[1] = 100;	  
        }
        break;
        }

      case UniformRandom:
      case SybilUniformRandom:
	// TODO: Think if this makes sense; why would a robot send a
	// random value?  Also for the Gaussian noise, I think it
	// makes more sense if this is just applied on the sensor and
	// not on the value sent
        toSend[1] = m_pcRNG->Uniform(CRange<int>(0, 100));
        break;
       
      case GaussianNoise: {
      case SybilGaussianNoise:

        Real p = m_pcRNG->Gaussian(0.05, 0.0);
        opinion.quality += p;

        /* Constrain it between 0.0 and 1.0 */
        if (opinion.quality > 1.0) {
          opinion.quality = 1.0;
        }

        if (opinion.quality < 0.0) {
          opinion.quality = 0.0;
        }
        break;
      }
    }



    
    if (byzantineStyle > 10 && byzantineStyle < 20) {
      /* Generate a random identity to steal identity from someone */
      CRange<UInt32> zero255(0, 255);
      UInt32 randomIdentity = m_pcRNG->Uniform(zero255);
      toSend[0] = randomIdentity;
    }

    /* Jamming attack */
    if (byzantineStyle ==  20) {
      toSend[3] = 1;
    }

    m_pcRABA->SetData(toSend);
    
  } else {
    m_sStateData.State = SStateData::STATE_DIFFUSING;  
  }


  /* Receive packets */
  const CCI_EPuckRangeAndBearingSensor::TPackets& tPackets = m_pcRABS->GetPackets();
  
  /* Determine how many non-initialized messages there are*/
  bool containedJammer = false;
  
  for(size_t i = 0; i < tPackets.size() ; ++i) {

    if (tPackets[i]->Data[3] == 1)
      containedJammer = true;
    
    /* Check if it is initialized and if a opinion of this robot was
       already received */
    if (tPackets[i]->Data[2] == 1 && !alreadyReceived[tPackets[i]->Data[0]]) {
      alreadyReceived[tPackets[i]->Data[0]] = true;
      if (receivedPackets.size() < simulationParams.maxStoredOpinions)
	receivedPackets.push_back(tPackets[i]->Data[1]);
      else
	receivedPackets[currentPosition] = tPackets[i]->Data[1];
      currentPosition = (currentPosition + 1) % simulationParams.maxStoredOpinions;
      }
  }

  if (containedJammer)
    receivedPackets.clear();
      
  m_pcRABS->ClearPackets();
  
}

/************************************************* DIFFUSING STATE *********************************************/
/***************************************************************************************************************/

void EPuck_Environment_Classification::Diffusing() {

  numExplorationPhase++;

  /* Make a snapshot of the current estimate*/
  
  /* Own estimate of this exploration phase */
  opinion.quality = (Real)((Real)(opinion.countedCellOfActualOpinion) / (Real)(collectedData.count));

  /* Add some noise to the sensor */
  if (byzantineStyle == 5 || byzantineStyle == 15) {
    Real p = m_pcRNG->Gaussian(0.05, 0.0);
    opinion.quality += p;

    /* Constraint it between 0.0 and 1.0 */
    if (opinion.quality > 1.0)
      opinion.quality = 1.0;

    if (opinion.quality < 0.0)
      opinion.quality = 0.0;
    
  }
    

  vector<int> msgs;
  vector<int> smaller_than;
  vector<int> greater_than;
  vector<int> msgs_cleaned;


  if (simulationParams.decisionRule == 1) {
    msgs_cleaned = receivedPackets;
  } else if (simulationParams.decisionRule == 2) {

    /* Apply W-SR */

    /* Parameter of the W-MSR algorithm */
    int F = 2;   

    std::sort(receivedPackets.begin(), receivedPackets.end());
  
    for (vector<int>::iterator it = receivedPackets.begin() ; it != receivedPackets.end(); ++it) {

       if (*it < opinion.quality)
	/* put into smaller than array */
	smaller_than.push_back(*it);
      
      else
	/* ...put into greater than array */
	greater_than.push_back(*it);
    }
        
    if (greater_than.size() < F) {
      greater_than.clear();
    } else {
      greater_than.resize(greater_than.size() - F);
    }
    
    if (smaller_than.size() < F) {
      smaller_than.clear();
    } else {
      smaller_than.erase(smaller_than.begin(), smaller_than.begin() + F);
    }
    
    msgs_cleaned.reserve( greater_than.size() + smaller_than.size() ); // preallocate memory
    msgs_cleaned.insert( msgs_cleaned.end(), greater_than.begin(), greater_than.end() );
    msgs_cleaned.insert( msgs_cleaned.end(), smaller_than.begin(), smaller_than.end() );
  } else {
    /* Unimplemented decision rule */
    THROW_ARGOSEXCEPTION("Unimplemented decision rule");
  }
  
  double weight = 1.0 / (msgs_cleaned.size() + 1);  

  currentQuality = opinion.quality * weight;

  if (Id2Int(GetId()) == 1) {

    std::ofstream robotOpinion;
    
    robotOpinion.open("robot1opinion.txt", std::ios_base::out | std::ios_base::app);

    robotOpinion << currentQuality << "," << opinion.countedCellOfActualOpinion << "," << collectedData.count << "," << totalQuality << ","  << endl;

    robotOpinion.close();
    
  }

  

  /* Apply the update rule */
  for (vector<int>::iterator it = msgs_cleaned.begin() ; it != msgs_cleaned.end(); ++it) {
    currentQuality += weight * (((double) *it) / 100.0);
  }
  
    if (byzantineStyle == 1) {
      totalQuality = 0.0;
      
    } else {
      totalQuality = totalQuality + (currentQuality - totalQuality) / ((double) numExplorationPhase);
      cout << "current quality is " << currentQuality << endl;
      cout << "Total quality is " << totalQuality << endl;
      //      cout << "tPackets.size is " << tPackets.size() << endl;
      cout << "num exp phase" << numExplorationPhase << endl;
    }


  opinion.countedCellOfActualOpinion = 0;
  collectedData.count = 0;
  

  /* Prepare packets vector again */
  for (int i = 0; i < 256; i++) {
    alreadyReceived[i] = false;
  }
  totalOpinionsReceived = 0;
  currentPosition = 0;
  receivedPackets.clear();
  

  /* Set remaining exploration time */
  
  /* Change to EXPLORING state and choose another opinion with decision rules */
  m_sStateData.State = SStateData::STATE_EXPLORING;

  /* Assigning a new exploration time, for the next exploration state */
    
  m_sStateData.remainingExplorationTime = simulationParams.explorationTime;
  m_sStateData.explorDurationTime = m_sStateData.remainingExplorationTime;
    
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

void EPuck_Environment_Classification::prepare(){

  opinion.countedCellOfActualOpinion = 0;
  opinion.quality = 0;
  collectedData.count = 0;
  
  opinion.mean = 0;
  opinion.M2 = 0;
  opinion.delta = 0.0;
  opinion.delta2 = 0.0;
  opinion.se = 0.0;

  CCI_EPuckRangeAndBearingActuator::TData toSend;

  currentQuality = 0.0;
  totalQuality = 0.0;
  numExplorationPhase = 0;

  toSend[0] = Id2Int(GetId());
  toSend[1] = totalQuality;
  toSend[2] = 0; /* 0: robot has not explored yet; 1: robot has explored */
  toSend[3] = 0; // a 1 here is used for simulating a jamming attack
  m_pcRABA->SetData(toSend);
  m_pcRABS->ClearPackets();
  TurnLeds();

  
  /* Assign the initial state of the robots: all in exploration state*/
  m_sStateData.State = SStateData::STATE_EXPLORING;

  /* Assign the exploration time (random generated) */
  //m_sStateData.remainingExplorationTime = (m_pcRNG->Exponential((Real)simulationParams.sigma));
  m_sStateData.remainingExplorationTime = simulationParams.explorationTime;
  m_sStateData.explorDurationTime = m_sStateData.remainingExplorationTime;
  
}

/****************************************/
/****************************************/


REGISTER_CONTROLLER(EPuck_Environment_Classification, "epuck_environment_classification_controller")
