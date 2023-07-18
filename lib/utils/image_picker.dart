import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

Future<PickedFile> pickImage(BuildContext context, bool image) async {
  PickedFile  _pickedImage;
  final imageSource = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 8.0, top: 8.0, bottom: 8.0),
                child: Text(image?'Select the image source':'Select the video source',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: new Icon(
                  Icons.photo_camera,
                  size: 35.0,
                  color: Colors.indigo,
                ),
                title: new Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: new Icon(
                  Icons.photo,
                  size: 35.0,
                  color: Colors.deepOrange,
                ),
                title: new Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      });



  if (imageSource != null) {

    final file = (image)
        ? await ImagePicker().getImage(source: imageSource, imageQuality: 80, maxHeight: 1000, maxWidth: 1000)
        : await ImagePicker().getVideo(source: imageSource, maxDuration: Duration(seconds: 30));

    if (file != null) {
      _pickedImage = file;
    }
  }
  return _pickedImage;
}

/*Future<String> pickImagee() async {
  File _pickedImage;
  final file = await ImagePicker.pickImage(source: ImageSource.gallery);
  if (file != null) {
    _pickedImage = file;
  }

  return base64Encode(_pickedImage.readAsBytesSync());
}*/

Future<List<Asset>> loadAssets(List<Asset> selectedImages) async {
  List<Asset> resultList = List<Asset>();
  String error = 'No Error Dectected';

  try {
    resultList = await MultiImagePicker.pickImages(
      maxImages: 300,
      enableCamera: true,
      selectedAssets: selectedImages,
      cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
      materialOptions: MaterialOptions(
        actionBarColor: "#8900FF",
        actionBarTitle: "Select Images",
        allViewTitle: "All Photos",
        actionBarTitleColor: "#FFFFFF",
        useDetailsView: false,
        statusBarColor: "#8900FF",
        selectCircleStrokeColor: "#000000",
      ),
    );
  } on Exception catch (e) {
    error = e.toString();
    print(e.toString());
  }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  return resultList;
}

Future<List<int>> compressFile(File file) async {
  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 1000,
    minHeight: 1000,
    quality: 60
  );
  return result;
}

Future<List<int>> compressList(List<int> list) async {
  var result = await FlutterImageCompress.compressWithList(
    list,
    minHeight: 1000,
    minWidth: 1000,
    quality: 60
  );
  return result;
}