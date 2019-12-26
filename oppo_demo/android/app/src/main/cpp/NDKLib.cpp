//
// Created by juhyg on 2019/4/16.
//
#include <android/bitmap.h>
#include <android/log.h>

#include <vector>

#include "com_example_oppo_demo_JNIFunction.h"
#include "net.h"
#include "mat.h"

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
JNIEXPORT jint JNICALL Java_com_example_oppo_1demo_JNIFunction_run
    (JNIEnv *env, jobject obj, jbyteArray array, jint w, jint h) {
  unsigned char* rgbdata = NULL;
  unsigned char* outdata = NULL;
  jbyte* bytes;
  bytes = env->GetByteArrayElements(array, 0);
  int len = env->GetArrayLength(array);
  rgbdata = new unsigned char[len + 1];
  memset(rgbdata, 0, len + 1);
  memcpy(rgbdata, bytes, len);
  rgbdata[len] = 0;

  env->ReleaseByteArrayElements(array, bytes, 0);

  ncnn::Mat in = ncnn::Mat::from_pixels(rgbdata, 1, w, h);

  ncnn::Mat out;
  ncnn::Extractor ex = net.create_extractor();

  ex.set_light_mode(true);
  ex.input(0, in);
  ex.extract(208, out);

  out.to_pixels(outdata, ncnn::Mat::PIXEL_RGB);

  int n = in.w + in.h + in.c;

  jbyteArray ret = env->NewByteArray(n);

  return n;
}