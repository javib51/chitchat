import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/chat/chat.dart';
import 'package:chitchat/common/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class GroupInitScreen extends StatefulWidget {
  final Set selectedUsers;
  GroupInitScreen({Key key, @required this.selectedUsers}) : super(key: key);

  @override
  State createState() => new GroupInitScreenState(selectedUsers: selectedUsers);
}

class GroupInitScreenState extends State<GroupInitScreen> {
  final Set selectedUsers;
  GroupInitScreenState({Key key, @required this.selectedUsers});

  var nickController = TextEditingController();
  File avatarImageFile;
  String photoUrl = "https://www.simplyweight.co.uk/images/default/chat/mck-icon-group.png";

  bool isLoading = false;

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    try {
      photoUrl = await storageTaskSnapshot.ref.getDownloadURL();
    } catch (e) {
      Fluttertoast.showToast(msg: "Upload fail");
      print(e.toString());
      return;
    }

    setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(msg: "Upload success");
  }

  Future handleUpdateData() async {
    setState(() {
      isLoading = true;
    });

    if (nickController.text
        .trim()
        .length == 0) {
      Fluttertoast.showToast(msg: "Please provide NickName");
    }
    else{
      var id = await Firestore.instance.collection('chats').add({
        'type': "G",
        'name': nickController.text.trim(),
        'photoUrl': photoUrl,
        'users': selectedUsers.toList()
      });
      await Firestore.instance
          .collection('chats')
          .document(id.documentID)
          .updateData({
        'id': id.documentID,
      });
      
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) =>
              new Chat(
                currentUserId: selectedUsers.last,
                chatId: id.documentID,
                chatAvatar: photoUrl,
              )));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final nickname = TextField(
      controller: nickController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Group Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),

    );

    final profilephoto = Container(
      child: Center(
        child: Stack(
          children: <Widget>[
            (avatarImageFile == null)
                ? (photoUrl != ''
                ? Material(
              child: CachedNetworkImage(
                placeholder: Container(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                  width: 90.0,
                  height: 90.0,
                  padding: EdgeInsets.all(20.0),
                ),
                imageUrl: photoUrl,
                width: 90.0,
                height: 90.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(45.0)),
              clipBehavior: Clip.hardEdge,
            )
                : Icon(
              Icons.account_circle,
              size: 90.0,
              color: greyColor,
            ))
                : Material(
              child: Image.file(
                avatarImageFile,
                width: 90.0,
                height: 90.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(45.0)),
              clipBehavior: Clip.hardEdge,
            ),
            IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: primaryColor.withOpacity(0.5),
              ),
              onPressed: getImage,
              padding: EdgeInsets.all(30.0),
              splashColor: Colors.transparent,
              highlightColor: greyColor,
              iconSize: 30.0,
            ),
          ],
        ),
      ),
      width: double.infinity,
      margin: EdgeInsets.all(20.0),
    );

    return Stack(

      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Set Group Info'),
            actions: <Widget>[
            ],
          ),
          body: Center(
            child: ListView(
              shrinkWrap: false,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                SizedBox(height: 40.0),
                profilephoto,
                SizedBox(height: 40.0),
                nickname,
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
              tooltip: 'Add',
              child: Icon(
                  Icons.done),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              onPressed: () {
                handleUpdateData();
              }
          ),
        ),
        Positioned(
          child: isLoading
              ? Container(
            child: Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
            ),
            color: Colors.white.withOpacity(0.8),
          )
              : Container(),
        ),
      ],
    );

  }
}