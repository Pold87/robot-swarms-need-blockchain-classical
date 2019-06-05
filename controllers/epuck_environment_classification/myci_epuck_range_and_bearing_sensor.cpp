/**
 * @file <argos3/plugins/robots/e-puck/control_interface/ci_epuck_range_and_bearing_sensor.cpp>
 *
 * @author Lorenzo Garattoni- <lgaratto@ulb.ac.be>
 */

#include "myci_epuck_range_and_bearing_sensor.h"
#include <argos3/core/utility/logging/argos_log.h>

namespace argos {

   /****************************************/
   /****************************************/

   void CCI_EPuckRangeAndBearingSensor::Init(TConfigurationNode& t_node) {
      /* get the data size from the configuration file or set it to the data struct size */
      /* sizeof return the number of byte */
      GetNodeAttributeOrDefault(t_node, "data_size", m_uDataSize, sizeof(TData));
      if (m_uDataSize > sizeof(TData)) {
         LOGERR << "[WARNING] RAB Sensor data_size=" << m_uDataSize
                << ", value incorrect, back to default value data_size=" << sizeof(TData) << std::endl;
         m_uDataSize = sizeof(TData);
      }
   }

   void CCI_EPuckRangeAndBearingSensor::ClearPackets() {
      while(!m_tPackets.empty()) {
         delete m_tPackets.back();
         m_tPackets.pop_back();
      }
   }

   /****************************************/
   /****************************************/

   std::ostream& operator<<(std::ostream& os,
                            const CCI_EPuckRangeAndBearingSensor::SReceivedPacket & t_packet) {
      os << "RAB_RECV_DATA < range = " << t_packet.Range
         << ", bearing horizontal = " << t_packet.Bearing
         << ", data = " << t_packet.Data;
      return os;
   }

   /****************************************/
   /****************************************/

}
