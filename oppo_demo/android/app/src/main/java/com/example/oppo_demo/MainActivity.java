package com.example.oppo_demo;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import android.os.Bundle;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "deeplab.ncnn/run";
  private JNIFunction s = new JNIFunction();
  private boolean isNetOk = false;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
          if (call.method.equals("init")) {
            initNet(result);
          } else if (call.method.equals("run")) {
            run((String)call.argument("imagePath"), result);
          } else {
            result.notImplemented();
          }
        }
      }
    );
  }

  private void initNet(Result result) {
    byte[] param = null;
    byte[] bin = null;

    try {
      param = readFromAssets("weights/deeplab_mob.param");
      bin = readFromAssets("weights/deeplab_mob.bin");
    } catch (Exception e) {
      result.error("Can not init!", e.toString(), null);
      return;
    }

    boolean isNetOk = s.init(param, bin);

    result.success(isNetOk);
  }

  private byte[] readFromAssets(String name) throws IOException {
    byte[] ptr;
    InputStream ins = getAssets().open(name);
    int available = ins.available();
    ptr = new byte[available];
    int code = ins.read(ptr);
    ins.close();
    return ptr;
  }

  private void run(String imagePath, Result result) {
    Bitmap image = BitmapFactory.decodeFile(imagePath);
    ByteArrayOutputStream stream = new ByteArrayOutputStream();
    image.compress(Bitmap.CompressFormat.PNG, 100, stream);

    int w = image.getWidth();
    int h = image.getHeight();

    byte[] imgBuffer = stream.toByteArray();

    byte[] res = s.run(imgBuffer, w, h);
    result.success(res);
  }
}
