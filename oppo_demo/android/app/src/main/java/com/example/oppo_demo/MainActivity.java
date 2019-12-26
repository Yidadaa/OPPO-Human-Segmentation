package com.example.oppo_demo;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Base64;

import android.os.Bundle;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.content.res.AssetManager;
import android.content.res.AssetFileDescriptor;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.PluginRegistry.Registrar;

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
            initNet(call, result);
          } else if (call.method.equals("run")) {
            run((String)call.argument("imagePath"), result);
          } else {
            result.notImplemented();
          }
        }
      }
    );
  }

  private void initNet(MethodCall call, Result result) {
    byte[] param = null;
    byte[] bin = null;

    String param_encoded = call.argument("param");
    String bin_encoded = call.argument("bin");

    param = Base64.getDecoder().decode(param_encoded);
    bin = Base64.getDecoder().decode(bin_encoded);

    boolean isNetOk = s.init(param, bin);

    result.success(isNetOk);
  }

  private void run(String imagePath, Result result) {
    Bitmap image = BitmapFactory.decodeFile(imagePath);
    ByteArrayOutputStream stream = new ByteArrayOutputStream();
    image.compress(Bitmap.CompressFormat.PNG, 100, stream);

    int w = image.getWidth();
    int h = image.getHeight();

    byte[] imgBuffer = stream.toByteArray();

    int res = s.run(imgBuffer, w, h);
    result.success(String.valueOf(res) + '_' + String.valueOf(imgBuffer.length));
  }
}
