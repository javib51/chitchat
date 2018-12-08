import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/common/imageResolution.dart';
import 'package:chitchat/common/translation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chitchat/const.dart';
import 'package:chitchat/overview/overview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  final String currentUserId;
  final SharedPreferences prefs;

  WelcomeScreen({Key key, @required this.currentUserId, @required this.prefs}) : super(key: key);

  @override
  WelcomeScreenState createState() => new WelcomeScreenState(currentUserId: currentUserId, prefs: this.prefs);
}
class WelcomeScreenState extends State<WelcomeScreen> {

  final SharedPreferences prefs;

  WelcomeScreenState({Key key, @required this.currentUserId, @required this.prefs});

  var nickController = TextEditingController();
  var aboutController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final String currentUserId;
  String id = '';
  String nickname = '';
  String photosResolution = '';
  String photoUrl = '';

  bool isLoading = false;

  File avatarImageFile;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() {
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    photosResolution = prefs.getString('photosResolution') ?? ImageResolution.full.toString().split('.').last;
    photoUrl = prefs.getString('photoUrl') ?? '';

    nickController = new TextEditingController(text: nickname);
    //aboutController = new TextEditingController(text: aboutMe);

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
      setState(() {
        isLoading = false;
      });
      return;
    }
    
    List<DocumentSnapshot> usersWithGivenNickname = (await Firestore.instance.collection("users").where("nickname", isEqualTo: nickController.text
        .trim()).getDocuments()).documents;

    if (usersWithGivenNickname.isNotEmpty) {
      Fluttertoast.showToast(msg: "The nickname provided already exists");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: currentUserId)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.isEmpty) {
      // Update data to server if new user
      Firestore.instance
          .collection('users')
          .document(currentUserId)
          .setData({
        'nickname': nickController.text.trim(),
        'photoUrl': photoUrl,
        'id': currentUserId,
        'photosResolution': photosResolution,
        'translation_mode': TranslationMode.onDemand.toString(),                //By default, on-demand translation is selected
        'translation_language': TranslationLanguage.english.toString(),         //By default, translation to english is selected
      });
    } else {
      Firestore.instance
          .collection('users')
          .document(id)
          .updateData({
        'nickname': nickController.text.trim(),
        'photosResolution': photosResolution,
        'photoUrl': photoUrl,
        'translation_mode': TranslationMode.onDemand.toString(),
        'translation_language': TranslationLanguage.english.toString()
      }).then((data) async {
        prefs.setString('nickname', nickController.text.trim());
        prefs.setString('photoUrl', photoUrl);
        prefs.setString('translation_mode', TranslationMode.onDemand.toString());
        prefs.setString('translation_language', TranslationLanguage.english.toString());
        });
      }

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainScreen(
                  currentUserId: currentUserId,
                  prefs: this.prefs,
                )),
      );
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


    return Stack(

    children: <Widget>[
      Scaffold(
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
              finregButton,
            ],
          ),
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
