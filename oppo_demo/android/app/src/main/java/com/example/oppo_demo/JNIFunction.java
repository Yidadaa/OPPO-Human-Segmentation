package com.example.oppo_demo;

public class JNIFunction {
    static {
        System.loadLibrary("native-lib");
    }

    public native String test(String name);
}
