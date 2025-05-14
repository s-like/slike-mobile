import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future OOffStage(Widget widget,
    {Duration? wait, bool openFilePreview = true, bool saveToDevice = false, String fileName = 'davinci', String? albumName, double? pixelRatio, bool returnImageUint8List = false}) async {
  /// finding the widget in the current context by the key.
  // final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

  /// create a new pipeline owner
  // final PipelineOwner pipelineOwner = PipelineOwner();

  /// create a new build owner
  // final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

  // Size logicalSize = ui.window.physicalSize / ui.window.devicePixelRatio;
  pixelRatio ??= View.of(Get.context!).devicePixelRatio;
  // assert(openFilePreview != returnImageUint8List);
}
