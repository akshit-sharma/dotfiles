cmake_minimum_required(VERSION 3.12.1)

project(dijkstra CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}/conan/")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_BINARY_DIR}/conan/")

if (NOT EXISTS "${CMAKE_BINARY_DIR}/conan/")
  file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/conan/")
endif()
if (NOT EXISTS "${CMAKE_BINARY_DIR}/conan/conan.cmake")
    message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
    file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/master/conan.cmake"
                  "${CMAKE_BINARY_DIR}/conan/conan.cmake")
endif()
include(${CMAKE_BINARY_DIR}/conan/conan.cmake)

conan_cmake_configure(REQUIRES
  cli11/1.9.1
  GENERATORS cmake_find_package_multi)

conan_cmake_autodetect(settings)

conan_cmake_install(PATH_OR_REFERENCE .
                    BUILD missing
                    REMOTE conancenter
                    INSTALL_FOLDER ${CMAKE_BINARY_DIR}/conan/
                    SETTINGS ${settings})

find_package(CLI11 CONFIG REQUIRED)

add_subdirectory(src)

if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json)
    execute_process(COMMAND ln -s ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json)
endif()
