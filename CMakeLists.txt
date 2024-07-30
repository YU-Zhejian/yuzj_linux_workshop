cmake_minimum_required(VERSION 3.10)
project(yuzj_linux_workshop LANGUAGES C)

add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/lab2/04_cmake_scp")

add_executable("hello_and_reboot" "${CMAKE_CURRENT_LIST_DIR}/lab4/hello.c")
add_executable("cond_comp" "${CMAKE_CURRENT_LIST_DIR}/lab2/01_shell_scp/cond_comp/test.c"
                           "${CMAKE_CURRENT_LIST_DIR}/lab2/01_shell_scp/includes/some_nasty_file.h")
