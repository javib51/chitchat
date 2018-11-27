import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
<<<<<<< HEAD
import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/common/Environment/storage_manager.dart';
import 'package:chitchat/common/Environment/firestore_user_profile_dao.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:chitchat/main_content/main_screen.dart';
import 'package:chitchat/common/const.dart';
=======
import 'package:chitchat/common/imageResolution.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chitchat/const.dart';
import 'package:chitchat/overview/overview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
>>>>>>> 83e4b079478b8ea2e192d33679414099c7d95982
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => new _WelcomeScreenState();
}
<<<<<<< HEAD
=======
class WelcomeScreenState extends State<WelcomeScreen> {
  WelcomeScreenState({Key key, @required this.currentUserId});
  var nickController = TextEditingController();
  var aboutController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final String currentUserId;
  String id = '';
  String nickname = '';
  String photosResolution = '';
  String photoUrl = '';
>>>>>>> 83e4b079478b8ea2e192d33679414099c7d95982

class _WelcomeScreenState extends State<WelcomeScreen> {

  PictureManager _storageManager = Environment.shared.pictureManager;
  FirestoreUserProfileDAO _userProfileDAO = Environment.shared.userProfileDAO;
  User _loggedInUser;

  TextEditingController _nickController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();
  File _avatarImageFile;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
=======
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    photosResolution = prefs.getString('photosResolution') ?? ImageResolution.full.toString().split('.').last;
    photoUrl = prefs.getString('photoUrl') ?? '';

    nickController = new TextEditingController(text: nickname);
    //aboutController = new TextEditingController(text: aboutMe);
>>>>>>> 83e4b079478b8ea2e192d33679414099c7d95982

    Environment.shared.credentialsSignInManager.getSignedInUser().then((User loggedInUser) {
      print(loggedInUser);
      this.setState(() {
        this._loggedInUser = loggedInUser;
        this._nickController.text = this._loggedInUser.nickname ?? "";
        this._aboutController.text = this._loggedInUser.aboutMe?? "";
      });
    });
<<<<<<< HEAD
=======

    if (nickController.text
        .trim()
        .length == 0) {
      Fluttertoast.showToast(msg: "Please provide NickName");
      return;
    }

    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: currentUserId)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // Update data to server if new user
      Firestore.instance
          .collection('users')
          .document(currentUserId)
          .setData({
        'nickname': nickController.text.trim(),
        'photoUrl': photoUrl,
        'id': currentUserId,
        'photosResolution': photosResolution,
      });
    } else {
      Firestore.instance
          .collection('users')
          .document(id)
          .updateData({
        'nickname': nickController.text.trim(),
        'photosResolution': photosResolution,
        'photoUrl': photoUrl
      }).then((data) async {
        await prefs.setString('nickname', nickController.text.trim());
        await prefs.setString('photoUrl', photoUrl);
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
                )),
      );
>>>>>>> 83e4b079478b8ea2e192d33679414099c7d95982
  }

  @override
  Widget build(BuildContext context) {

    final formFieldDecoration = (String hint) => InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0)
    );

<<<<<<< HEAD
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
=======
    final finregButton = Padding(
>>>>>>> 83e4b079478b8ea2e192d33679414099c7d95982
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
<<<<<<< HEAD
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
=======
              SizedBox(height: 40.0),
              profilephoto,
              SizedBox(height: 40.0),
              nickname,
              SizedBox(height: 40.0),
              finregButton,
            ],
          ),
>>>>>>> 83e4b079478b8ea2e192d33679414099c7d95982
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

  Future<void> _handleSubmitDataPress() async {

    print("***** CC *****");

    if (this._nickController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please provide NickName");
      return;
    }

    print("***** DD *****");

    String aboutMeContent = this._aboutController.text == null || this._aboutController.text.trim().isEmpty ? "Hey there! I'm using ChitChat!" : this._aboutController.text.trim();

    print("***** EE *****");

    print(this._loggedInUser);

    User userToSave = User(
        aboutMe: aboutMeContent,
        nickname: this._nickController.text.trim(),
        pictureURL: this._loggedInUser.pictureURL,
        uid: this._loggedInUser.uid
    );

    await this._userProfileDAO.update(userToSave, true);

    this.setState(() {});

    Fluttertoast.showToast(msg: "Update success");
    Navigator.pop(context);
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
      String userPictureURL = this._loggedInUser?.pictureURL;

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
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    try {
      await this._uploadFile(image: image);
      this.setState(() {});
      Fluttertoast.showToast(msg: "Image uploaded.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Image upload failed.");
    }
  }

  Future<String> _uploadFile({@required File image}) async {
    if (image == null) return null;

    String fileName = this._loggedInUser.uid;
    String pictureURL = await this._storageManager.uploadPicture(picture: image, pictureName: fileName);

    return pictureURL;
  }
}
