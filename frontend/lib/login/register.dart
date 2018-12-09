import 'package:chitchat/common/translation.dart';
import 'package:chitchat/const.dart';
import 'package:chitchat/login/welcome.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {

  SharedPreferences prefs;

  RegisterScreen({@required this.prefs});

  @override
  RegisterScreenState createState() => new RegisterScreenState(prefs: this.prefs);
}

class RegisterScreenState extends State<RegisterScreen> {

  SharedPreferences prefs;
  bool isLoading = false;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passController = TextEditingController();

  RegisterScreenState({@required this.prefs});

  void handleRegister() async {

    this.setState(() {
      isLoading = true;
    });

    if (emailController.text == null || emailController.text.length == 0) {
      Fluttertoast.showToast(msg: "Please provide email");
      this.setState(() {
        isLoading = false;
      });
      return;
    }

    else if (passController.text == null || passController.text.length < 6) {
      Fluttertoast.showToast(msg: "Minimal password length is 6");
      this.setState(() {
        isLoading = false;
      });
      return;
    }

    List<String> providers = await firebaseAuth.fetchProvidersForEmail(email: emailController.text);

    if (providers != null && providers.length > 0) {
      Fluttertoast.showToast(msg: "email already exists");
      this.setState(() {
        isLoading = false;
      });
      return;
    }
    FirebaseUser firebaseUser;
    try {
      firebaseUser = await firebaseAuth.createUserWithEmailAndPassword(
          email: emailController.text.trim(), password: passController.text.trim());
    } catch (e) {
      Fluttertoast.showToast(msg: "Register fail");
      print(e.toString());
      this.setState(() {
        isLoading = false;
      });
      return;
    }

    await prefs.clear();
    prefs.setString('id', firebaseUser.uid);
    prefs.setString('photoUrl', "https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/OOjs_UI_icon_userAvatar.svg/1024px-OOjs_UI_icon_userAvatar.svg.png");
    prefs.setString('translation_mode', TranslationMode.onDemand.toString());
    prefs.setString('translation_language', TranslationLanguage.english.toString());

    Fluttertoast.showToast(msg: "Register succes");
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WelcomeScreen(
            currentUserId: firebaseUser.uid,
            prefs: this.prefs,
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

    return Stack(

    children: <Widget>[
      Scaffold(
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
