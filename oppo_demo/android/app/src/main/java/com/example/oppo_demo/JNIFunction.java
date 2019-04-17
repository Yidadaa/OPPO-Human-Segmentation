package com.example.oppo_demo;

public class JNIFunction {
    static {
        System.loadLibrary("native-lib");
    }

    public native boolean init(byte[] param, byte[] bin);
    public native byte[] run(byte[] image, int w, int h);
}
