cmake_minimum_required(VERSION 3.4.1)

set(NCNN_LIB ${CMAKE_SOURCE_DIR}/src/main/cpp/ncnn-android-lib/${ANDROID_ABI}/libncnn.a)

include_directories(${CMAKE_SOURCE_DIR}/src/main/cpp/ncnn-android-lib/include)

add_library(NCNN_LIB STATIC IMPORTED)
set_target_properties(NCNN_LIB PROPERTIES IMPORTED_LOCATION ${NCNN_LIB})

add_library(native-lib SHARED src/main/cpp/NDKLib.cpp)

target_link_libraries(native-lib NCNN_LIB)