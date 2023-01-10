add_executable(hello
  main.cpp)

target_compile_features(hello PRIVATE
  cxx_std_17)
set_target_properties(hello PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
  )
target_link_libraries(hello PRIVATE
  CLI11::CLI11
  )
