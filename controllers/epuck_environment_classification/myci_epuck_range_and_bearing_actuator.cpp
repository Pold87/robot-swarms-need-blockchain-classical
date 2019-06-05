/**
 * @file <argos3/plugins/robots/e-puck/simulator/epuck_range_and_bearing_default_actuator.cpp>
 *
 * @author Gianpiero Francesca <gianpiero.francesca@ulb.ac.be>
 * @author Lorenzo Garattoni <lgaratto@ulb.ac.be>
 */

#include "myci_epuck_range_and_bearing_actuator.h"
#include <argos3/core/utility/logging/argos_log.h>

namespace argos {

   /****************************************/
   /****************************************/


   /****************************************/
   /****************************************/

   void MYCCI_EPuckRangeAndBearingActuator::Init(TConfigurationNode& t_tree) {
      try {
         /* get the data size from the configuration file or set it to the data struct size */
         /* sizeof return the number of byte */

           GetNodeAttributeOrDefault(t_tree, "data_size", m_uDataSize, sizeof(TData));
         if (m_uDataSize > sizeof(TData)) {
            LOGERR << "[WARNING] RAB actuator data_size=" << m_uDataSize
                   << ", value incorrect, back to default value data_size=" << sizeof(TData) << std::endl;
            m_uDataSize = sizeof(TData);
         }
      } catch (CARGoSException& ex) {
         THROW_ARGOSEXCEPTION_NESTED("Error initializing range-and-bearing actuator", ex);
      }
   }
   /****************************************/
   /****************************************/

   void MYCCI_EPuckRangeAndBearingActuator::SetData(const TData t_data) {
      m_sDesiredData.State = STATE_ALL_EMITTERS_SAME_DATA;
      for(size_t i = 0; i < 12; ++i) {
         m_sDesiredData.Emitter[i].Enabled = true;
         m_sDesiredData.Emitter[i].Data[0] = t_data[0];
         m_sDesiredData.Emitter[i].Data[1] = t_data[1];
         m_sDesiredData.Emitter[i].Data[2] = t_data[2];
         m_sDesiredData.Emitter[i].Data[3] = t_data[3];
      }
   }

   /****************************************/
   /****************************************/

   void MYCCI_EPuckRangeAndBearingActuator::SetDataForEmitter(size_t un_idx,
                                                             const TData t_data) {
      m_sDesiredData.State = STATE_EMITTERS_DIFFERENT;
      m_sDesiredData.Emitter[un_idx].Enabled = true;
      m_sDesiredData.Emitter[un_idx].Data[0] = t_data[0];
      m_sDesiredData.Emitter[un_idx].Data[1] = t_data[1];
      m_sDesiredData.Emitter[un_idx].Data[2] = t_data[2];
      m_sDesiredData.Emitter[un_idx].Data[3] = t_data[3];
   }

   /****************************************/
   /****************************************/

   void MYCCI_EPuckRangeAndBearingActuator::Disable() {
      m_sDesiredData.State = STATE_ALL_EMITTERS_DISABLED;
      for(size_t i = 0; i < 12; ++i) {
         m_sDesiredData.Emitter[i].Enabled = false;
      }
   }

   /****************************************/
   /****************************************/

   void MYCCI_EPuckRangeAndBearingActuator::DisableEmitter(size_t un_idx) {
      m_sDesiredData.State = STATE_EMITTERS_DIFFERENT;
      m_sDesiredData.Emitter[un_idx].Enabled = false;
   }


   /****************************************/
   /****************************************/
   MYCCI_EPuckRangeAndBearingActuator::SDataToSend::SDataToSend() :
      State(STATE_ALL_EMITTERS_DISABLED) {
      for(size_t i = 0; i < 12; ++i) {
         Emitter[i].Enabled = false;
         ::memset(&(Emitter[i].Data), 0, sizeof(Emitter[i].Data));
      }
   }

   MYCCI_EPuckRangeAndBearingActuator::SDataToSend::SDataToSend(const MYCCI_EPuckRangeAndBearingActuator::SDataToSend& s_data) :
      State(s_data.State) {
      for(size_t i = 0; i < 12; ++i) {
         Emitter[i].Enabled = s_data.Emitter[i].Enabled;
         Emitter[i].Data[0] = s_data.Emitter[i].Data[0];
         Emitter[i].Data[1] = s_data.Emitter[i].Data[1];
         Emitter[i].Data[2] = s_data.Emitter[i].Data[2];
         Emitter[i].Data[3] = s_data.Emitter[i].Data[3];
      }
   }

   MYCCI_EPuckRangeAndBearingActuator::SDataToSend&
   MYCCI_EPuckRangeAndBearingActuator::SDataToSend::operator=(
           const MYCCI_EPuckRangeAndBearingActuator::SDataToSend& s_data) {
      if(this != &s_data) {
         State = s_data.State;
         for(size_t i = 0; i < 12; ++i) {
            Emitter[i].Enabled = s_data.Emitter[i].Enabled;
            Emitter[i].Data[0] = s_data.Emitter[i].Data[0];
            Emitter[i].Data[1] = s_data.Emitter[i].Data[1];
            Emitter[i].Data[2] = s_data.Emitter[i].Data[2];
            Emitter[i].Data[3] = s_data.Emitter[i].Data[3];

         }
      }
      return *this;
   }

   /****************************************/
   /****************************************/
}
