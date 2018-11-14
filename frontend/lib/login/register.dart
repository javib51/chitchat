import 'package:chitchat/login/welcome.dart';
import 'package:chitchat/overview/overview.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterScreenState createState() => new RegisterScreenState();
}

class NickPhotoScreen extends StatefulWidget {
  final FirebaseUser currentUser;

  NickPhotoScreen({Key key, @required this.currentUser}) : super(key: key);

  @override
  NickPhotoScreenState createState() => new NickPhotoScreenState(currentUser: currentUser);
}

class NickPhotoScreenState extends State<NickPhotoScreen> {
  NickPhotoScreenState({Key key, @required this.currentUser});
  final nickController = TextEditingController();
  final FirebaseUser currentUser;
  final myController = TextEditingController();

  SharedPreferences prefs;

  bool isLoading = false;

  Future<Null> finalRegister() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .setData({
      'nickname': nickController.text,
      'photoUrl': null,
      'id': currentUser.uid
    });


    await prefs.setString('id', currentUser.uid);
    await prefs.setString('nickname', currentUser.displayName);
    await prefs.setString('photoUrl', currentUser.photoUrl);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MainScreen(
            currentUserId: currentUser.uid,
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
          onPressed: finalRegister,
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
        constraints: BoxConstraints(
            maxHeight: 120.0,
            maxWidth: 120.0,
            minWidth: 120.0,
            minHeight: 120.0
        ),
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image: new NetworkImage(
                    "https://i.imgur.com/BoN9kdC.png")
            )
        ));


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
            nickname,
            SizedBox(height: 40.0),
            finregButton,
          ],
        ),
      ),
    );
  }
}

class RegisterScreenState extends State<RegisterScreen> {
  SharedPreferences prefs;
  bool isLoading = false;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passController = TextEditingController();

  Future<Null> handleRegister() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    if (emailController.text == null || emailController.text.length == 0) {
      Fluttertoast.showToast(msg: "Please provide email");
      return;
    }

    else if (passController.text == null || passController.text.length < 6) {
      Fluttertoast.showToast(msg: "Minimal password length is 6");
      return;
    }

    List<String> providers = await firebaseAuth.fetchProvidersForEmail(email: emailController.text);

    if (providers != null && providers.length > 0) {
      Fluttertoast.showToast(msg: "email already exists");
      return;
    }
    FirebaseUser firebaseUser;
    try {
      firebaseUser = await firebaseAuth.createUserWithEmailAndPassword(
          email: emailController.text, password: passController.text);
    } catch (e) {
      Fluttertoast.showToast(msg: "Register fail");
      print(e.toString());
      return;
    }

    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .setData({
      'nickname': "Unknown",
      'photoUrl': null,
      'id': firebaseUser.uid,
    });

    await prefs.clear();
    await prefs.setString('id', firebaseUser.uid);

    Fluttertoast.showToast(msg: "Register succes");
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WelcomeScreen(
            currentUserId: firebaseUser.uid,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
    );

    final password = TextFormField(
      controller: passController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
    );

    final registerButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
          onPressed: handleRegister,
          child: Text(
            "CREATE ACCOUNT",
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          color: Colors.amber,
          highlightColor: Colors.blueGrey,
          splashColor: Colors.transparent,
          textColor: Colors.white,
          padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
    );
    final loginButton = FlatButton(
        child: Text(
          'Already have an account?',
          style: TextStyle(color: Colors.black54),
        ),
        onPressed: () {
          Navigator.pop(context);
        }
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            new Text(
              "Register",
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontFamily: "Roboto",
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            registerButton,
            loginButton
          ],
        ),
      ),
    );
  }
}
