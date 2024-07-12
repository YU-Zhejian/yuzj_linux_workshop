cmake_minimum_required(VERSION 3.11)
project(
    stupid_c_progs
    VERSION 0.1
    LANGUAGES C)

macro(ceu_cm_set_static_target name)
    set_target_properties("${name}" PROPERTIES LINK_SEARCH_START_STATIC 1)
    set_target_properties("${name}" PROPERTIES LINK_SEARCH_END_STATIC 1)
    set_target_properties("${name}" PROPERTIES INSTALL_RPATH "")
    if(CMAKE_VERSION GREATER_EQUAL 3.13
       AND NOT BORLAND
       AND NOT MSVC)
        target_link_options("${name}" PRIVATE -static -static-libgcc)
    endif()
endmacro()

add_compile_options(${CEU_CM_ADDITIONAL_COMPILER_FLAGS})

include_directories("${CMAKE_CURRENT_LIST_DIR}/../src")
add_library(main_lib SHARED "${CMAKE_CURRENT_LIST_DIR}/../src/stupid.c")
add_library(main_lib_static STATIC "${CMAKE_CURRENT_LIST_DIR}/../src/stupid.c")
ceu_cm_set_static_target(main_lib_static)

add_executable(main_exe "${CMAKE_CURRENT_LIST_DIR}/../src/main.c")
add_executable(main_exe_static "${CMAKE_CURRENT_LIST_DIR}/../src/main.c")
ceu_cm_set_static_target(main_exe_static)

target_link_libraries(main_exe main_lib)
target_link_libraries(main_exe_static main_lib_static)

enable_testing()
add_test(NAME main_exe COMMAND main_exe)
add_test(NAME main_exe_static COMMAND main_exe_static)
