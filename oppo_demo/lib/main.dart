import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';

import 'utils.dart';
import 'gallary.dart';

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
  File latestFile;

  void switchCamera() {
    setState(() {
      cameraIndex = 1 - cameraIndex;
    });
    initCamera();
  }

  void regfreshImageIcon() async {
    File _latestFile = await getLatestImageFile();
    setState(() {
      latestFile = _latestFile;
    });
  }

  void initCamera() {
    var _camController =
        CameraController(cameras[cameraIndex], ResolutionPreset.medium);
    _camController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        camController = _camController;
      });
    });
  }

  Future<String> takePicture() async {
    String imgPath = await getNewImagePath();
    if (camController.value.isTakingPicture) {
      return null;
    }
    try {
      await camController.takePicture(imgPath);
    } catch (e) {
      print(e);
      return null;
    }
    File thumbFile = await buildThumbnailOf(imgPath);
    setState(() {
      latestFile = thumbFile;
    });
    return thumbFile.path;
  }

  void gotoGallery() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GallaryPage()));
  }

  Widget titleBar() {
    const double iconSize = 16.0;
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon([Icons.camera_front, Icons.camera_rear][cameraIndex],
                color: Colors.white),
            iconSize: iconSize,
            onPressed: switchCamera,
          ),
          IconButton(
            icon: Icon(
              Icons.blur_on,
              color: Colors.white,
              size: iconSize,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.color_lens,
              color: Colors.white,
              size: iconSize,
            ),
            onPressed: () {},
          ),
        ]);
  }

  Widget actionBar() {
    const double iconSize = 40.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.videocam,
            color: Colors.white,
          ),
          iconSize: iconSize,
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.album,
          ),
          color: Colors.white,
          iconSize: iconSize * 2,
          onPressed: takePicture,
        ),
        latestFile == null
            ? IconButton(
                icon: Icon(
                  Icons.image,
                ),
                color: Colors.white,
                iconSize: iconSize,
                onPressed: gotoGallery,
              )
            : InkWell(
                child: Image.file(
                  latestFile,
                  width: iconSize,
                ),
                onTap: gotoGallery,
              )
      ],
    );
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
    if (camController == null || !camController.value.isInitialized) {
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
