import 'package:flutter/material.dart';

import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/common/const.dart';
import 'package:chitchat/main_content/main_screen.dart';
import 'package:chitchat/login/login_screen.dart';

class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  bool _isUserLoggedIn;

  @override
  void initState() async {
    super.initState();

    this._isUserLoggedIn = await Environment.shared.credentialsSignInManager.isUserSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChitChat',
      theme: new ThemeData(
        primaryColor: themeColor,
      ),
      home: this._chooseRightScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  //Chooses which screen to start the application with, depending whether there is a logged user or not.
  Widget _chooseRightScreen() {
    return this._isUserLoggedIn ? MainScreen() : LoginScreen();
  }

}