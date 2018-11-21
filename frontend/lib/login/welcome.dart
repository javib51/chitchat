import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/common/Environment/storage_manager.dart';
import 'package:chitchat/common/Environment/firestore_user_profile_dao.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:chitchat/main_content/main_screen.dart';
import 'package:chitchat/common/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => new _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  PictureManager _storageManager = Environment.shared.pictureManager;
  FirestoreUserProfileDAO _userProfileDAO = Environment.shared.userProfileDAO;
  User _loggedInUser;

  TextEditingController _nickController;
  TextEditingController _aboutController;
  File _avatarImageFile;

  @override
  void initState() async {
    super.initState();

    this._loggedInUser = await Environment.shared.credentialsSignInManager.getSignedInUser();
    this._nickController = new TextEditingController(text: this._loggedInUser.nickname ?? "");
    this._aboutController = new TextEditingController(text: this._loggedInUser.aboutMe ?? "");
  }

  @override
  Widget build(BuildContext context) {

    final formFieldDecoration = (String hint) => InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0)
    );

    final nicknameTextField = TextField(
      controller: this._nickController,
      autofocus: false,
      decoration: formFieldDecoration("NickName"),
    );

    final aboutTextField = TextField(
      controller: this._aboutController,
      autofocus: false,
      decoration: formFieldDecoration("About you"),
    );

    final completeRegistrationButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
          onPressed: this._handleSubmitDataPress,
          child: Text(
            "LET'S CHITCHAT",
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          color: Colors.amber,
          highlightColor: Colors.blueGrey,
          splashColor: Colors.transparent,
          textColor: Colors.white,
          padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)
      ),
    );

    final profilePictureContainer = this._getProfilePictureContainer();

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
            profilePictureContainer,
            SizedBox(height: 40.0),
            nicknameTextField,
            SizedBox(height: 40.0),
            aboutTextField,
            SizedBox(height: 40.0),
            completeRegistrationButton,
          ],
        ),
      ),
    );
  }

  void _handleSubmitDataPress() {

    if (this._nickController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please provide NickName");
      return;
    }

    String aboutMeContent = "Hey there! I'm using ChitChat!";

    if (this._aboutController.text.trim().isNotEmpty) {
      aboutMeContent = this._aboutController.text.trim();
    }

    User userToSave = User(aboutMe: aboutMeContent, nickname: this._nickController.text.trim(), pictureURL: this._loggedInUser.pictureURL, uid: this._loggedInUser.uid);

    this._userProfileDAO.create(userToSave, true);

    this.setState(() {});

    Fluttertoast.showToast(msg: "Update success");
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MainScreen(),
      )
    );
  }

  Widget _getProfilePictureContainer() {

    List<Widget> innerWidgets;

    if (this._avatarImageFile == null) {
      String userPictureURL = this._loggedInUser.pictureURL;

      if (userPictureURL == null) { // ignore: null_aware_in_condition
        innerWidgets = [Icon(
          Icons.account_circle,
          size: 90.0,
          color: greyColor,
        )];
      } else {
        innerWidgets = [Material(
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
            imageUrl: userPictureURL,
            width: 90.0,
            height: 90.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(45.0)),
          clipBehavior: Clip.hardEdge,
        )];
      }
    } else {
      innerWidgets = [
        Material(
          child: Image.file(
            this._avatarImageFile,
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
          onPressed: this._handleProfileImageIconPress,
          padding: EdgeInsets.all(30.0),
          splashColor: Colors.transparent,
          highlightColor: greyColor,
          iconSize: 30.0,
        )
      ];
    }

    return Container(
        child: Center(
            child: Stack(
              children: innerWidgets,
            )
        )
    );
  }

  Future<void> _handleProfileImageIconPress() async {
    File image = await this._getImage();
    try {
      await this._uploadFile(image: image);
      this.setState(() {});
      Fluttertoast.showToast(msg: "Image uploaded.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Image upload failed.");
    }
  }

  Future<File> _getImage() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<String> _uploadFile({@required File image}) async {
    if (image == null) return null;

    String fileName = this._loggedInUser.uid;
    String pictureURL = await this._storageManager.uploadPicture(picture: image, pictureName: fileName);

    return pictureURL;
  }
}
