import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

String rootDir = '';
String thumbDir = '';
String compressedDir = '';

Future initFolder() async {
  final Directory extDir = await getApplicationDocumentsDirectory();
  rootDir = '${extDir.path}/Pictures/';
  thumbDir = '${extDir.path}/Thumbnail/';
  compressedDir = '${extDir.path}/Compressed/';
  await Directory(rootDir).create(recursive: true);
  await Directory(thumbDir).create(recursive: true);
  await Directory(compressedDir).create(recursive: true);
}

Future<String> getNewImagePath() async {
  if (rootDir.isEmpty) await initFolder();
  return '$rootDir/${timestamp()}.jpg';
}

Future<File> buildThumbnailOf(String imgPath) async {
  String ts = basename(imgPath).replaceAll('.jpg', '');
  String thumbPath = '$thumbDir$ts.jpg';
  String compressedPath = '$compressedDir$ts.jpg';
  File thumbFile = await FlutterNativeImage.compressImage(imgPath, quality: 20, percentage: 20);
  final _thumbFile = await thumbFile.copy(thumbPath);
  thumbFile.delete();
  File compressedFile = await FlutterNativeImage.compressImage(imgPath, targetWidth: 480, targetHeight: 480);
  await compressedFile.copy(compressedPath);
  compressedFile.delete();

  return _thumbFile;
}

Future<File> getLatestImageFile() async {
  List<File> files = await getAllImageFiles(thumbDir);
  File latestFile = files.reduce((a, b) =>
      a.lastModifiedSync().compareTo(b.lastModifiedSync()) > 0 ? a : b);
  return latestFile;
}

Future<List<File>> getAllImageFiles(String dir, {sort: false}) async {
  Directory picDir = Directory(dir);
  List<FileSystemEntity> imgs = await picDir.list().toList();
  List<File> files = imgs.map((img) => File(img.path)).toList();
  if (sort) {
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
  }
  return files;
}

String getSrcPathOf(String path) {
  print("[getSrcPathOf]" + path);
  String base = basename(path);
  return rootDir + base;
}

String getCompressedPathOf(String path) {
  print("[getCompressedPathOf]" + path);
  String base = basename(path);
  return compressedDir + base;
}

Future initNet(MethodChannel platform) async {
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
