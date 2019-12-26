import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';

import 'utils.dart';

class ImagePage extends StatefulWidget {
  ImagePage({Key key, this.imagePath}) : super(key: key);
  final String imagePath;

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  double value = 0.0;
  static const platform = const MethodChannel('deeplab.ncnn/run');

  void onSliderChange(double v) {
    setState(() {
      value = v;
    });
  }

  void deleteImage() {
    File(widget.imagePath).delete();
    Navigator.pop(context);
  }

  void run() async {
    var res = await platform.invokeMethod("run", {
      "imagePath": getCompressedPathOf(widget.imagePath)
    });
    print(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: run,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteImage,
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: CircularProgressIndicator(),
          ),
          Column(
            children: <Widget>[
              Image.file(File(widget.imagePath)),
              Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Slider(
                        value: value,
                        min: 0,
                        max: 12.0,
                        onChanged: onSliderChange,
                      ),
                      Text("拖动上方滑动条以调整虚化力度")
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}
