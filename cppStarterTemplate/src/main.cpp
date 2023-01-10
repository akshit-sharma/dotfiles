#include <iostream>
#include <optional>
#include <CLI/CLI.hpp>

struct Arguments {};

std::optional<Arguments> commandParser(int argc, char *argv[]) {
  CLI::App app{"Command line parser"};

  try {
    app.parse(argc, argv);
  } catch (const CLI::ParseError &e) {
    if (app.exit(e) != 0) {
      throw e;
    }
    return {};
  }
  return {{}};
}

int myMain(const Arguments &arguments) {
  std::cout << "Hello world " << std::endl;
  return 0;
}

int main(int argc, char *argv[]) {
  try {
    const auto arguments = commandParser(argc, argv);

    if (!arguments.has_value())
      return 0;

    return myMain(arguments.value());
  } catch (const std::exception &e) {
    std::cerr << "Error: " << e.what() << std::endl;
    return 1;
  }
}
