import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

Future takePicture({required contentKey, required BuildContext context, required saveToGallery}) async {
  try {
    /// converter widget to image
    RenderRepaintBoundary boundary = contentKey.currentContext.findRenderObject();

    ui.Image image = await boundary.toImage(pixelRatio: 2.5);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    /// create file
    final String dir = (await getApplicationDocumentsDirectory()).path;
    String imagePath = '$dir/stories_creator${DateTime.now().microsecondsSinceEpoch}.png';
    File capturedFile = File(imagePath);
    await capturedFile.writeAsBytes(pngBytes);

    if (saveToGallery) {
      final result = await ImageGallerySaverPlus.saveImage(pngBytes, quality: 100, name: "stories_creator${DateTime.now().microsecond}.png");
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return imagePath;
    }
  } catch (e) {
    debugPrint('exception => $e');
    return false;
  }
}
