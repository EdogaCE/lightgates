import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<List<File>> pickMultiFiles(BuildContext context) async {

 //todo: Single file
  //File file = await FilePicker.getFile();
  //todo: Multiple files
  //List<File> files = await FilePicker.getMultiFile();
  //todo: Multiple files with extension filter
  List<File> files = await FilePicker.getMultiFile(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'pdf', 'doc', 'xls', 'ppt', 'png', 'gif', 'jpeg', 'docs'],
  );
  return files;
}

Future<File> createFileOfPdfUrl({String urlP = '', String fileNameExtension}) async {
  if (await Permission.storage.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    final url = urlP;
    String fileDate = '${DateTime.now().microsecondsSinceEpoch}';
    var request = await HttpClient()?.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;

    File fileSave = new File('$dir/$fileDate.$fileNameExtension');
    await fileSave.writeAsBytes(bytes);

    return fileSave;
  }
  return null;
}