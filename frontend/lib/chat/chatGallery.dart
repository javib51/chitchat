import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/const.dart';
import 'package:quiver/collection.dart';

class ChatGallery extends StatelessWidget {
  final String groupChatId;
  final Future<Map<String, DocumentSnapshot>> chatUsers;
  final option = new ValueNotifier("Sender");

  ChatGallery(this.groupChatId, this.chatUsers);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT GALLERY',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: option,
        builder: (context, value, child) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                DropDownMenu(
                  option: option,
                ),
                GalleryPart(
                  groupChatId: groupChatId,
                  option: option,
                ),
              ],
            ),
          );
        },
      ), //new ChatSettingsScreen(),
    );
  }
}

class DropDownMenu extends StatefulWidget {
  final List<String> _options = ["Sender", "Features"].toList();
  final option;
  DropDownMenu({Key key, @required this.option}) : super(key: key);

  @override
  createState() => DropdownMenuState();
}

class DropdownMenuState extends State<DropDownMenu> {
  DropdownMenuState();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final dropdownMenuOptions = widget._options
        .map((String option) => new DropdownMenuItem<String>(
            value: option, child: new Text(option)))
        .toList();

    return new Container(
      height: deviceSize.height / 10,
      child: ValueListenableBuilder<String>(
        valueListenable: widget.option,
        builder: (context, valueListened, child) {
          return Center(
            child: DropdownButton(
              value: valueListened,
              items: dropdownMenuOptions,
              onChanged: (value) {
                widget.option.value = value;
              },
            ),
          );
        },
      ),
    );
  }
}

class GalleryPart extends StatefulWidget {
  final ValueListenable<String> option;
  final String groupChatId;

  GalleryPart({Key key, @required this.groupChatId, @required this.option})
      : super(key: key);

  @override
  createState() => GalleryPartState(this.groupChatId, this.option);
}

class GalleryPartState extends State<GalleryPart> {
  ValueListenable<String> option;
  String groupChatId;
  Future<QuerySnapshot> images;

  var currentState;
  Map<String, Future<Multimap<String, ImageData>>> states = {"Sender": null, "Features": null};

  var listMessages;

  GalleryPartState(this.groupChatId, this.option);

  void initState() {
    super.initState();

    currentState = states["Sender"] = this.getImagesBySender();
  }

  Future<Multimap<String, ImageData>> getImagesBySender() async {
    Multimap<String, ImageData> multimap = new Multimap<String, ImageData>();
    
    var result = await Firestore.instance
        .collection('chats')
        .document(widget.groupChatId)
        .collection('messages')
        .where("type", isEqualTo: "photo")
        //.orderBy('timestamp', descending: true)
        .limit(10)
        .getDocuments();
    result.documents.forEach((f) => multimap.add(
        f.data['nickname'],
        new ImageData(f.data['nickname'], f.data['payload'],
            f.data['timestamp'], f.data['label'])));
    
    return multimap;
  }

  Future<Multimap<String, ImageData>> getImagesByFeature() async {
    Multimap<String, ImageData> multimap = new Multimap<String, ImageData>();
    
    var result = await Firestore.instance
        .collection('chats')
        .document(widget.groupChatId)
        .collection('messages')
        .where("type", isEqualTo: "photo")
        //.orderBy('timestamp', descending: true)
        .limit(10)
        .getDocuments();

    result.documents.forEach((f) => multimap.add(
        f.data['label'],
        new ImageData(f.data['nickname'], f.data['payload'],
            f.data['timestamp'], f.data['label'])));

    return multimap;
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    option.addListener(() {
      if(states[option.value] == null) {
        switch (option.value) {
          case "Sender":
            states[option.value] = this.getImagesBySender();
            break;
          case "Features":
            states[option.value] = this.getImagesByFeature();
            break;
        }
      }

      currentState = states[option.value];
    });
  
    return new Container(
      height: deviceSize.height / 1.4,
      child: FutureBuilder(
          future: currentState,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(15.0),
                children: listMyWidgets(snapshot.data),
              );
            } else {
              return Container();
            }
          }
      ),
    );
  }

  List<Widget> listMyWidgets(Multimap<String, ImageData> mapImageData) {
    List<Widget> list = new List();
    mapImageData.forEachKey((k, v) {
      list.add(
        Center(
            child: Text(
              k,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            )
        ),
      );
      List<Container> imagesContainer =
          new List<Container>.generate(v.length, (int index) {
        return Container(
          child: CachedNetworkImage(
            errorWidget: Material(
              child: Image.asset(
                'images/img_not_available.jpeg',
                fit: BoxFit.fill,
              ),
            ),
            imageUrl: v.elementAt(index).payload,
            fit: BoxFit.fill,
          ),
        );
      });
      list.add(
        IgnorePointer(
          ignoring: true,
          child: GridView.extent(
            shrinkWrap: true,
            maxCrossAxisExtent: 150.0,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            padding: const EdgeInsets.all(5.0),
            children: imagesContainer, //Where is this function ?
          ),
        ),
      );
    });
    return list;
  }
}

class ImageData {
  String _nickname;
  String _payload;
  String _timestamp;
  String _label;

  ImageData(String n, String p, String t, String f) {
    this._nickname = n;

    this._payload = p;
    this._timestamp = t;
    this._label = f;
  }

  String get nickname => this._nickname;
  String get payload => this._payload;
  String get timestamp => this._timestamp;
  String get label => this._label;

  @override
  String toString() {
    // TODO: implement toString
    return "Nickname: $nickname, Payload: $payload, Timestamp: $timestamp, Feature: $label";
  }
}
