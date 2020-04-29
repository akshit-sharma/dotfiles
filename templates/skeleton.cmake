cmake_minimum_required(VERSION 3.14)

# set your project name
project()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CONAN_SYSTEM_INCLUDES "On")

if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/conan.cmake")
  message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
  file (DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/master/conan.cmake"
                 "${CMAKE_CURRENT_BINARY_DIR}/conan.cmake")
endif()
include ("${CMAKE_CURRENT_BINARY_DIR}/conan.cmake")
conan_cmake_run(
  CONANFILE conanfile.txt
  BASIC_SETUP
  BUILD missing)

add_subdirectory(src)

add_custom_target(copy_compile_commands
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json)
add_custom_command(
  TARGET copy_compile_commands
  PRE_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
   ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
   ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json
  )
