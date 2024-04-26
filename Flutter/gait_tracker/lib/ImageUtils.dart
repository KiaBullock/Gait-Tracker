import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageUtils {
  static Future<Uint8List> mergeImages(List<Uint8List> imageDatas) async {
    List<ui.Image> images = await _convertToUiImages(imageDatas);

    int width = images.map((image) => image.width).reduce((a, b) => a > b ? a : b);
    int height = images.map((image) => image.height).reduce((a, b) => a + b);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(width.toDouble(), height.toDouble())));

    double offsetY = 0;
    for (var image in images) {
      canvas.drawImage(image, Offset(0, offsetY), Paint());
      offsetY += image.height;
      // canvas.drawColor(Colors.white, BlendMode.modulate);
    }

    final picture = recorder.endRecording();

    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static Future<List<ui.Image>> _convertToUiImages(List<Uint8List> imageDatas) async {
    List<Future<ui.Image>> futures = imageDatas.map((imageData) => _convertToUiImage(imageData)).toList();
    return Future.wait(futures);
  }

  static Future<ui.Image> _convertToUiImage(Uint8List imageData) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    final codec = await ui.instantiateImageCodec(imageData);
    final frameInfo = await codec.getNextFrame();
    completer.complete(frameInfo.image);
    return completer.future;
  }
}
