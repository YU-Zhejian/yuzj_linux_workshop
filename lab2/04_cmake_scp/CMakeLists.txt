cmake_minimum_required(VERSION 3.12)
project(
    stupid_c_progs
    VERSION 0.1
    LANGUAGES C)
# Generate `compile_commands.json`, required for SonarLint.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# For -DBUILT_UNDER_CMAKE
add_compile_definitions(BUILT_UNDER_CMAKE)

include(GNUInstallDirs)
# Set initial RPATH
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_FULL_LIBDIR}")
# Allow automatic determination of RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

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

include_directories("${CMAKE_CURRENT_LIST_DIR}/../src")
add_library(main_lib SHARED "${CMAKE_CURRENT_LIST_DIR}/../src/stupid.c")
add_library(main_lib_static STATIC "${CMAKE_CURRENT_LIST_DIR}/../src/stupid.c")
ceu_cm_set_static_target(main_lib_static)

add_executable(main_exe "${CMAKE_CURRENT_LIST_DIR}/../src/main.c")
add_executable(main_exe_static "${CMAKE_CURRENT_LIST_DIR}/../src/main.c")
ceu_cm_set_static_target(main_exe_static)

target_link_libraries(main_exe main_lib)
target_link_libraries(main_exe_static main_lib_static)

install(FILES "${CMAKE_CURRENT_LIST_DIR}/../src/stupid.h" TYPE INCLUDE)
install(TARGETS main_lib main_lib_static main_exe main_exe_static)

enable_testing()
add_test(NAME main_exe COMMAND main_exe)
add_test(NAME main_exe_static COMMAND main_exe_static)
