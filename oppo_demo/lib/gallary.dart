import 'package:flutter/material.dart';
import 'dart:io';

import 'image.dart';
import 'utils.dart';

class GallaryPage extends StatefulWidget {
  @override
  _GallaryPageState createState() => _GallaryPageState();
}

class _GallaryPageState extends State<GallaryPage> {
  List<File> files = [];

  void showImage(File f) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImagePage(imagePath: getSrcPathOf(f.path))));
  }

  void loadImages() async {
    if (thumbDir.isEmpty) {
      await initFolder();
    }
    getAllImageFiles(thumbDir, sort: true).then((_files) {
      setState(() {
        files = _files;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("已拍摄图片"),
          backgroundColor: Colors.black,
        ),
        body: Container(
          color: Colors.black,
          child: GridView.count(
            crossAxisCount: 4,
            children: files.map((f) {
              return InkWell(
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.file(f).image,
                  )),
                ),
                onTap: () => showImage(f),
              );
            }).toList(),
          ),
        ));
  }
}
