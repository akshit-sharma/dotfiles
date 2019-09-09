cmake_minimum_required(VERSION 3.14)

# set your project name
set(EXE exec)
project(${EXE} CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CONAN_SYSTEM_INCLUDES "On")

include (${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

add_executable(${EXE} main.cpp)
target_link_libraries(${EXE} ${CONAN_LIBS})

add_custom_command(TARGET ${EXE}
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json)
