cmake_minimum_required(VERSION 3.4.1)

set(NCNN_LIB ${CMAKE_SOURCE_DIR}/src/main/cpp/ncnn-android-lib/${ANDROID_ABI}/libncnn.a)

link_libraries(${NCNN_LIB})
include_directories(${CMAKE_SOURCE_DIR}/src/main/cpp/ncnn-android-lib/include)

add_library(native-lib SHARED src/main/cpp/NDKLib.cpp)