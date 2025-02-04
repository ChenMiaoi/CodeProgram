#include <iostream>
#include <stdlib.h>
#include <string>
#include <variant>

#include "src/include/defs.h"
#include "src/include/json.h"

int main(int, char**){
    info << "test info";
    debug << "test debug";
    warn << "test warn";
    erron << "test error";
    fatal << "test fatal";

    simple_json test;
    test.version();

    using namespace std::string_literals;
    auto json = test.parse("\"world\" hello \\r\bheww"s);
    info << *json;
}
