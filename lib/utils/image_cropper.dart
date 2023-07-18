import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

Future<File> cropImage(File imageFile) async {
  File newImageFile;
  File croppedFile = await ImageCropper.cropImage(
    sourcePath: imageFile.path,
    aspectRatioPresets: Platform.isAndroid
        ? [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ]
        : [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio5x3,
      CropAspectRatioPreset.ratio5x4,
      CropAspectRatioPreset.ratio7x5,
      CropAspectRatioPreset.ratio16x9
    ],
    androidUiSettings: AndroidUiSettings(
        toolbarTitle: ' ',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
        title: ' ',
        aspectRatioLockEnabled: false,
        hidesNavigationBar: true,
        cancelButtonTitle: 'Cancel',
        doneButtonTitle: 'Done',
      )
  );
  if (croppedFile != null) {
    newImageFile = croppedFile;
  }

  return newImageFile;
}