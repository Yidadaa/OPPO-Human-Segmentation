import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  cameras = await availableCameras();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black, statusBarColor: Colors.black));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('deeplab.ncnn/run');
  CameraController camController;
  int cameraIndex = 0;

  Future initNet() async {
    ByteData param = await rootBundle.load("weights/deeplab_mob.param");
    ByteData bin = await rootBundle.load("weights/deeplab_mob.bin");
    String pstr = base64.encode(param.buffer.asUint8List());
    String bstr = base64.encode(bin.buffer.asUint8List());
    print(param.buffer.asUint8List().length);
    print(bin.buffer.asUint8List().length);
    var result =
        await platform.invokeMethod("init", {"param": pstr, "bin": bstr});
    print("res: " + result.toString());
  }

  Widget titleBar() {
    const double iconSize = 16.0;
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(
              [Icons.camera_front, Icons.camera_rear][cameraIndex],
              color: Colors.white,
              size: iconSize,
            ),
            onPressed: switchCamera,
          ),
          IconButton(
            icon: Icon(
              Icons.screen_rotation,
              color: Colors.white,
              size: iconSize,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.screen_rotation,
              color: Colors.white,
              size: iconSize,
            ),
            onPressed: () {},
          ),
        ]);
  }

  Widget actionBar() {
    const double size = 40.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.videocam,
          color: Colors.white,
          size: size,
        ),
        Icon(
          Icons.album,
          color: Colors.white,
          size: size * 2,
        ),
        Icon(
          Icons.image,
          color: Colors.white,
          size: size,
        )
      ],
    );
  }

  void switchCamera() {
    setState(() {
      cameraIndex = 1 - cameraIndex;
    });
    initCamera();
  }

  void initCamera() {
    var _camController = CameraController(cameras[cameraIndex], ResolutionPreset.medium);
    _camController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        camController = _camController;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    camController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!camController.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: SafeArea(
          child: Container(
              color: Colors.black,
              child: Column(
                children: [
                  titleBar(),
                  AspectRatio(
                      aspectRatio: camController.value.aspectRatio,
                      child: CameraPreview(camController)),
                  Expanded(
                    child: actionBar(),
                  )
                ],
              ))),
    );
  }
}
