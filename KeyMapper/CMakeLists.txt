cmake_minimum_required(VERSION 3.25)

project(KeyMapper VERSION 0.1
    DESCRIPTION "Run Lua script to create macros and mappings for multi-button mice like Logitech G600, Razer Naga, Redragon M990"
    LANGUAGES C CXX)

find_package(Lua REQUIRED)

if(NOT DEFINED KEYMAPPER_ETC_DIR)
    set(KEYMAPPER_ETC_DIR "/etc/local")
endif()

add_executable(KeyMapper DeviceFile.hh DeviceFile.cc ConfigFile.hh ConfigFile.cc KeyMapper.cc)
target_include_directories(KeyMapper PUBLIC ${LUA_INCLUDE_DIR})
target_link_libraries(KeyMapper PUBLIC ${LUA_LIBRARIES})
target_compile_definitions(KeyMapper PUBLIC KEYMAPPER_ETC_DIR=${KEYMAPPER_ETC_DIR})
