import 'package:flutter/material.dart';
import 'dart:io';

import 'utils.dart';

class GallaryPage extends StatefulWidget {
  @override
  _GallaryPageState createState() => _GallaryPageState();
}

class _GallaryPageState extends State<GallaryPage> {
  List<File> files = [];

  @override
  void initState() {
    super.initState();
    getAllImageFiles(thumbDir, sort: true).then((_files) {
      setState(() {
        files = _files;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("已拍摄图片"),
        backgroundColor: Colors.black,
      ),
      body: GridView.count(
        crossAxisCount: 4,
        children: files.map((f) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.file(f).image,
              )
            ),
          );
        }).toList(),
      ),
    );
  }
}
