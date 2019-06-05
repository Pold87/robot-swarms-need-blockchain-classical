include_directories(${CMAKE_SOURCE_DIR}/controllers)

add_library(controllers SHARED 
	    helpers.h
	    helpers.cpp
	    epuck_environment_classification.h 
            epuck_environment_classification.cpp
)
	    
target_link_libraries(controllers
  argos3core_simulator
  argos3plugin_simulator_epuck
  argos3plugin_simulator_genericrobot)


