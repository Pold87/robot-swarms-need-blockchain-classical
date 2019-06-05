#ifndef EPUCK_ENVIRONMENT_CLASSIFICATION_H
#define EPUCK_ENVIRONMENT_CLASSIFICATION_H
#include <argos3/core/control_interface/ci_controller.h>
#include <argos3/core/utility/configuration/argos_configuration.h>


//#include "myci_epuck_range_and_bearing_actuator.h"
//#include "myci_epuck_range_and_bearing_sensor.h"


#include <argos3/plugins/robots/e-puck/control_interface/ci_epuck_range_and_bearing_actuator.h>
#include <argos3/plugins/robots/e-puck/control_interface/ci_epuck_range_and_bearing_sensor.h>


#include <argos3/plugins/robots/e-puck/control_interface/ci_epuck_proximity_sensor.h>
#include <argos3/plugins/robots/generic/control_interface/ci_differential_steering_actuator.h>
#include <argos3/plugins/robots/generic/control_interface/ci_leds_actuator.h>
#include <argos3/plugins/robots/e-puck/control_interface/ci_epuck_ground_sensor.h>
#include <argos3/plugins/robots/e-puck/control_interface/ci_epuck_wheels_actuator.h>

#include <argos3/core/utility/math/rng.h>
#include <argos3/core/utility/math/vector2.h>
#include <vector>
#include <set>
#include <string>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <ctime>
#include <iostream>

#define N_COL  3

using namespace argos;

class EPuck_Environment_Classification : public CCI_Controller {
  
public:
	 struct CollectedData {
	     CColor readColor;
	     UInt32 count;
	     CollectedData();
	  };

	 struct MyPacket {
	   int id;
	   int value;
	   MyPacket();
	 };

	  struct Opinion {
	    UInt32 actualOpinion;
	    UInt32 countedCellOfActualOpinion;
	    Real quality;
	    double mean;
	    double delta;
	    double delta2;
	    double M2;
	    double se;	    
	    CColor actualOpCol;
	    Opinion();
	  };

	  // Random walk
	  struct Movement {
	    SInt32 walkTime;         // Movement time counter;
	    UInt32 actualDirection;  // 0, straight; 1, turn CW; 2, turn CCW (TOCHECK: if 1 is counterclockwise or vice versa; fix comment)
	    Movement();
	  };

	  struct SimulationState {
	    UInt32 decisionRule;
	    Real percentRed, percentBlue;
	    Real g;
	    Real sigma;
	    bool exitFlag;
	    bool profiling;
	    std::string radix;
	    std::string baseDir; /* Basedir of the controller folder */
	    std::string datadirBase;
	    UInt32 numPackSaved;
	    int maxStoredOpinions;
	    int explorationTime;
	    UInt32 status;
	    UInt32 LAMBDA, turn;
	    UInt32 numRobots; /* total amount of robots in the experiment */
	    void Init(TConfigurationNode& t_node);
	  };

	  struct SStateData {

	    /* For variables for the time of the states because t
	       wo of them are decreased to count the time
	       * steps spent in that state and the other two are used to keep track of the duration times, for
	       * record the statistics.
	       */
	     SInt32 explorDurationTime;
	     SInt32 remainingExplorationTime;
	     SInt32 diffusingDurationTime;
	     SInt32 remainingDiffusingTime;

	     enum EState {
	         STATE_EXPLORING,
	         STATE_DIFFUSING,
	      } State;};
public:
   /* Class constructor. */
   EPuck_Environment_Classification();
 
   /* Class destructor. */
   virtual ~EPuck_Environment_Classification() {}

   virtual void Init(TConfigurationNode& t_node);
   virtual void ControlStep();
   virtual void RandomWalk();
   virtual void Reset() {};
   void prepare();
   void Explore();
   void Diffusing();   
   void Move();
   void TurnLeds();
   Real ExponentialFormula(Real mean){

     CRange<Real> cRange(0.0,1.0);
     return -log(m_pcRNG->Uniform(cRange)) * mean;
   }

   virtual void Destroy() {}

   inline CollectedData& GetColData() {
      return collectedData;
   }
   inline SStateData& GetStateData() {
      return m_sStateData;
   }
   inline SimulationState& GetSimulationState(){
      return simulationParams;
   }
   inline Movement & GetMovement() {
      return movement;
   }
   inline Opinion & GetOpinion() {
      return opinion;
   }

   inline bool IsExploring() const {
      return m_sStateData.State == SStateData::STATE_EXPLORING;
   }
   inline bool IsDiffusing() const {
      return m_sStateData.State == SStateData::STATE_DIFFUSING;
   }

   inline int getNodeInt() {
     return nodeInt;
   }

   inline int getByzantineStyle() {
     return byzantineStyle;
   }

   inline double getTotalQuality() {
     return totalQuality;
   }

   inline int getNumExplorationPhase() {
     return numExplorationPhase;
   }
      

   inline bool getConsensusReached() {
     return consensusReached;
   }
   
   inline void setByzantineStyle(int style) {
     byzantineStyle = style;
   }
   
   void UpdateNeighbors(std::set<int> newNeighbors);

     enum ByzantineStyle { 
       No = 0,
       AlwaysZero = 1, AlwaysOne = 2, RandomZeroOne = 3, UniformRandom = 4, GaussianNoise = 5,
       SybilAlwaysZero = 11, SybilAlwaysOne = 12, SybilRandomZeroOne = 13,
       SybilUniformRandom = 14, SybilGaussianNoise = 15,
       Jamming = 20
     };


private:

   void readNodeMapping();

   CCI_EPuckWheelsActuator* m_pcWheels;
   Real m_fWheelVelocity;
   CCI_EPuckRangeAndBearingActuator*  m_pcRABA;
   CCI_EPuckRangeAndBearingSensor* m_pcRABS;
   CDegrees m_cAlpha;                         // OBST. AVOID.
   Real m_fDelta;                             // OBST. AVOID.
   CCI_EPuckProximitySensor* m_pcProximity;   // OBST. AVOID.
   CRange<CRadians> m_cGoStraightAngleRange;  // OBST. AVOID.
   CCI_LEDsActuator* m_pcLEDs;
   CRandom::CRNG* m_pcRNG;

   /* Files */
   std::ofstream epuckFile;
   /* Data structures for collect opinions in diffusing state */
   /* All others used variables */
   SStateData m_sStateData;
   SimulationState simulationParams;
    std::ofstream numberReceived;		// Flag: just robot "ff0" (always present) writes his qualities after each exp. state
   CollectedData collectedData;
   Opinion opinion;
   Movement movement;

   int initializationValues[N_COL];
   std::set<int> neighbors;

   bool beginning;
   int nodeInt;
   std::map<int, int> robotIdToNode;  
   int byzantineStyle;
   bool consensusReached;
   double currentQuality;
   int numExplorationPhase;
   double totalQuality;
   CColor red, blue, green;
   UInt8 explorationCounter;
   std::vector<int> receivedPackets;
   int currentPosition;
   UInt32 totalOpinionsReceived;
   bool alreadyReceived[256];

   
};

#endif
