import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/const.dart';
import 'package:chitchat/overview/overview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  final String currentUserId;

  WelcomeScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  WelcomeScreenState createState() => new WelcomeScreenState(currentUserId: currentUserId);
}
class WelcomeScreenState extends State<WelcomeScreen> {
  WelcomeScreenState({Key key, @required this.currentUserId});
  var nickController = TextEditingController();
  var aboutController = TextEditingController();

  final String currentUserId;
  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  bool isLoading = false;

  File avatarImageFile;

  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    nickController = new TextEditingController(text: nickname);
    aboutController = new TextEditingController(text: aboutMe);

    // Force refresh input
    setState(() {});
  }

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
    String fileName = id;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    photoUrl = await storageTaskSnapshot.ref.getDownloadURL();
    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'nickname': nickname, 'aboutMe': aboutMe, 'photoUrl': photoUrl}).then((data) async {
      await prefs.setString('photoUrl', photoUrl);
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Upload success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {

    setState(() {
      isLoading = true;
    });

    if (nickController.text.trim().length == 0) {
      Fluttertoast.showToast(msg: "Please provide NickName");
      return;
    }

    if (nickController.text.trim().length == 0){
      nickController.text = "available";
    }

    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'nickname': nickController.text.trim(), 'aboutMe': aboutController.text.trim(), 'photoUrl': photoUrl}).then((data) async {
      await prefs.setString('nickname', nickController.text.trim());
      await prefs.setString('aboutMe', aboutController.text.trim());
      await prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(
              currentUserId: currentUserId,
            )),
      );

    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {

    final nickname = TextField(
      controller: nickController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'NickName',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),

    );

    final about = TextField(
      controller: aboutController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'About you',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),

    );

    final finregButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
          onPressed: handleUpdateData,
          child: Text(
            "LET'S CHITCHAT",
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          color: Colors.amber,
          highlightColor: Colors.blueGrey,
          splashColor: Colors.transparent,
          textColor: Colors.white,
          padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
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


    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            new Text(
              "Set your Profile",
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontFamily: "Roboto",
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40.0),
            profilephoto,
            SizedBox(height: 40.0),
            nickname,
            SizedBox(height: 40.0),
            about,
            SizedBox(height: 40.0),
            finregButton,
          ],
        ),
      ),
    );
  }

}
