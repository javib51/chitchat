import 'dart:async';

import 'package:chitchat/common/Models/signup_credentials.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:chitchat/login/register.dart';
import 'package:chitchat/login/welcome.dart';
import 'package:chitchat/main_content/main_screen.dart';
import 'package:chitchat/common/Models/google_credentials.dart';

enum _LoginType {
  signupCredentials, google
}

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final formFieldDecoration = (String hint) => InputDecoration(
      hintText: hint,
      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0)
    );

    final emailFormField = TextFormField(
      controller: this._emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: formFieldDecoration("Email")
    );

    final passwordFormField = TextFormField(
      controller: _passController,
      autofocus: false,
      obscureText: true,
      decoration: formFieldDecoration("Password")
    );

    final regularLoginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
          onPressed: () => this._handleLogin(_LoginType.signupCredentials),
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
          onPressed: () => this._handleLogin(_LoginType.google),
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
            emailFormField,
            SizedBox(height: 8.0),
            passwordFormField,
            SizedBox(height: 24.0),
            regularLoginButton,
            googleLoginButton,
            registerButton,
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(_LoginType loginType) async {

    User loggedUser;

    try {
      switch (loginType) {
        case _LoginType.google: {
          GoogleSignInAuthentication googleAuth = await (await GoogleSignIn().signIn()).authentication;

          loggedUser = await Environment.shared.googleSignInManager.signIn(GoogleCredentials(
              accessToken: googleAuth.accessToken, idToken: googleAuth.idToken));
          }
          break;
        case _LoginType.signupCredentials: {
            loggedUser = await Environment.shared.credentialsSignInManager.signIn(SignupCredentials(
              email: this._emailController.text,
              password: this._passController.text,
            ));
          }
          break;
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Sign in fail");
      print("Sign in error: $error");
    }

    DAO<User> userProfileDAO = Environment.shared.userProfileDAO;

    try {
      await userProfileDAO.create(loggedUser, false);
      Fluttertoast.showToast(msg: "Sign in success");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen()
        )
      );
    } on DAOException {         //User already existing
      //User existing
      MaterialPageRoute(
          builder: (context) => loggedUser.nickname != null ? MainScreen() : WelcomeScreen()
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Sign in failed");
      print(e);
    }
  }
}
