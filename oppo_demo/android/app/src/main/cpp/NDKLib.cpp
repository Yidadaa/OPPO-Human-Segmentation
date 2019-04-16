//
// Created by juhyg on 2019/4/16.
//

#include "com_example_oppo_demo_JNIFunction.h"

JNIEXPORT jstring JNICALL Java_com_example_oppo_1demo_JNIFunction_test
  (JNIEnv *env, jobject obj, jstring name) {
    return name;
}