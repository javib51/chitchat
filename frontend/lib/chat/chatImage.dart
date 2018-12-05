import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chitchat/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker_saver/image_picker_saver.dart';


class ChatImage extends StatefulWidget {
  final String imageUrl;

  ChatImage(this.imageUrl);

  @override
  createState() => ChatImageState();
}

class ChatImageState extends State<ChatImage> {

  Widget imageDisplay() => Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: PhotoView(
      backgroundDecoration: BoxDecoration(color: Colors.white70),
      //enableRotation: true,
      imageProvider: NetworkImage(widget.imageUrl),
      ) 
  );

  @override
  Widget build(BuildContext context) {
    
    print(widget.imageUrl);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Image',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {
              downloadImage(widget.imageUrl);
            }
          ),
        ],
      ),
      body: imageDisplay(), //new ChatSettingsScreen(),
    );
  }

  void downloadImage(String url) async {
    print("downloading...");
    print(url);
    var response = await get(url);
    var filePath = await ImagePickerSaver.saveFile(fileData: response.bodyBytes);
    print(filePath.toString());
    var savedFile = File.fromUri(Uri.file(filePath));
    Fluttertoast.showToast(
      msg: "Image saved to gallery",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  }
}
