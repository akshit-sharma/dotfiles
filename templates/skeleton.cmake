cmake_minimum_required(VERSION 3.14)

# set your project name
project()

set(CONAN_SYSTEM_INCLUDES "On")
if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/conan.cmake")
  message(STATUS "Downloading conan.cmake from \
          https://github.com/conan-io/cmake-conan")
  file (DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/master/conan.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/conan.cmake")
endif()
include("${CMAKE_CURRENT_BINARY_DIR}/conan.cmake")
conan_cmake_run(
  CONANFILE conanfile.txt
  BASIC_SETUP
  BUILD missing)

add_subdirectory(src)
