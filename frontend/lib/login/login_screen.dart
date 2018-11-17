import 'dart:async';

import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/common/Environment/login_manager.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:chitchat/login/register.dart';
import 'package:chitchat/login/welcome.dart';
import 'package:chitchat/main_content/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _LoginType {
  emailPassword, google
}

class LoginScreen extends StatefulWidget {

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final LoginManager _loginManager = Environment.shared.loginManager;

  @override
  Widget build(BuildContext context) {

    final formFieldDecoration = (String hint) => InputDecoration(
      hintText: hint,
      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0)
    );

    final email = TextFormField(
      controller: this._emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: formFieldDecoration("Email")
    );

    final password = TextFormField(
      controller: _passController,
      autofocus: false,
      obscureText: true,
      decoration: formFieldDecoration("Password")
    );

    final regularLoginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
          onPressed: () => this.handleSignIn(_LoginType.emailPassword),
          child: Text(
            'SIGN IN',
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          color: Colors.amber,
          highlightColor: Colors.blueGrey,
          splashColor: Colors.transparent,
          textColor: Colors.white,
          padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
    );

    final googleLoginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: FlatButton(
          onPressed: () => this.handleSignIn(_LoginType.google),
          child: Text(
            'CONNECT WITH GOOGLE',
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          color: Colors.blueGrey,
          highlightColor: Colors.white30,
          splashColor: Colors.transparent,
          textColor: Colors.white,
          padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
    );

    final registerButton = FlatButton(
        child: Text(
          'Create Account',
          style: TextStyle(color: Colors.black54),
        ),
        onPressed: () {
          Navigator.push(
            this.context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
        }

    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            regularLoginButton,
            googleLoginButton,
            registerButton,
          ],
        ),
      ),
    );
  }

  Future<void> handleSignIn(_LoginType loginType) async {
    FirebaseUser firebaseUser;

    try {
      switch (loginType) {
        case _LoginType.google:
          {
            firebaseUser = await this.handleGoogleSignIn();
          }
          break;

        case _LoginType.emailPassword:
          {
            firebaseUser = await this.handleRegularSingIn();
          }
          break;
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Sign in fail");
      print("Sign in error: $error");
    }

    // Check is already sign up
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    if (documents.isEmpty) {
      // Update data to server if new user

      // Write data to local
      User currentUser = User(nickname: firebaseUser.displayName,
          uid: firebaseUser.uid,
          pictureURL: firebaseUser.photoUrl);
      this._loginManager.saveUser(user: currentUser, forced: true);

      Fluttertoast.showToast(msg: "Sign in success");

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WelcomeScreen()
        ),
      );
    } else {
      User newUser = User(nickname: documents[0]['nickname'],
          uid: documents[0]['id'],
          pictureURL: documents[0]['photoUrl']);
      this._loginManager.saveUser(user: newUser, forced: true);

      Fluttertoast.showToast(msg: "Sign in success");

      //???
      if (documents[0]['nickname']
          .toString()
          .isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WelcomeScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen()),
        );
      }
    }
  }

  Future<FirebaseUser> handleGoogleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    return await _firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<FirebaseUser> handleRegularSingIn() async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text
    );
  }
}
