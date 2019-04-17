//
// Created by juhyg on 2019/4/16.
//
#include <android/bitmap.h>
#include <android/log.h>

#include <vector>

#include "com_example_oppo_demo_JNIFunction.h"
#include "net.h"

static std::vector<unsigned char> param_buf;
static std::vector<unsigned char> bin_buf;
static ncnn::Net net;

/*
 * Class:     com_example_oppo_demo_JNIFunction
 * Method:    init
 * Signature: ([B[B)Z
 */
JNIEXPORT jboolean JNICALL Java_com_example_oppo_1demo_JNIFunction_init
    (JNIEnv *env, jobject instance, jbyteArray param, jbyteArray bin) {
  bool res = true;
  // init param
  {
    int len = env->GetArrayLength(param);
    param_buf.resize(len);
    env->GetByteArrayRegion(param, 0, len, (jbyte*)param_buf.data());
    int ret = net.load_param(param_buf.data());
    res = ret == 0;
  }
  // init bin
  {
    int len = env->GetArrayLength(bin);
    bin_buf.resize(len);
    env->GetByteArrayRegion(bin, 0, len, (jbyte*)bin_buf.data());
    int ret = net.load_model(bin_buf.data());
    res = ret == 0;
  }

  return res;
}

/*
 * Class:     com_example_oppo_demo_JNIFunction
 * Method:    run
 * Signature: (Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;
 */
JNIEXPORT jbyteArray JNICALL Java_com_example_oppo_1demo_JNIFunction_run
    (JNIEnv *, jobject, jbyteArray, jint, jint) {
  return NULL;
}