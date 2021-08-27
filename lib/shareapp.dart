import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class shareapp{
  static Future<void> shareFile(appName, fileToShare) async {
    ByteData data;
    Uint8List fileBytes;


    try{
      //print('Getting Bytes');
      File file = File(fileToShare);
      fileBytes = await file.readAsBytes();
      data = fileBytes.buffer.asByteData();
      var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      //final ByteData bytes = await rootBundle.load(fileToShare);
      //print('done');
      await Share.files(
          'esys images',
          {
            '$appName.apk': data.buffer.asUint8List()

          },
          'image/png');

    }catch(e){
      print('error : $e');
    }
    //print(fileToShare);
  }

}