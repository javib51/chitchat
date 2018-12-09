import 'dart:async';

import 'package:chitchat/common/translation.dart';
import 'package:chitchat/login/register.dart';
import 'package:chitchat/login/welcome.dart';
import 'package:chitchat/common/imageResolution.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/const.dart';
import 'package:chitchat/overview/overview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';



class MyApp extends StatelessWidget {

  final SharedPreferences prefs;

  MyApp({@required this.prefs});

  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primaryColor: Colors.amber,
        primarySwatch: Colors.amber,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: 'ChitChat',
          theme: theme,
          home: this.prefs.get("id") == null ? LoginScreen(prefs: this.prefs,) : MainScreen(currentUserId: this.prefs.get("id"), prefs: this.prefs,),
          debugShowCheckedModeBanner: false,
        );
      }
    );

  }
}

class LoginScreen extends StatefulWidget {

  final SharedPreferences prefs;

  LoginScreen({Key key, @required this.prefs}) : super(key: key);

  @override
  LoginScreenState createState() => new LoginScreenState(prefs: this.prefs);
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passController = TextEditingController();

  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  LoginScreenState({@required this.prefs});



  @override
  void initState() {
    super.initState();

  }



  Future<Null> handleSignIn(String logintype) async {

    this.setState(() {
      isLoading = true;
    });

    FirebaseUser firebaseUser;
    if(logintype == 'google') {
      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      firebaseUser = await firebaseAuth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } else {
      firebaseUser = await firebaseAuth.signInWithEmailAndPassword(
          email: emailController.text, password: passController.text)
          .catchError((e) {
        Fluttertoast.showToast(msg: "Sign in fail");
        this.setState(() {
          isLoading = false;
        });
      });
    }

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user

        // Write data to local
        currentUser = firebaseUser;
        await prefs.clear();
        prefs.setString('id', currentUser.uid);
        prefs.setString('nickname', currentUser.displayName);
        prefs.setString('photoUrl', currentUser.photoUrl);
        prefs.setString('photosResolution', ImageResolution.full.toString().split('.').last);
        prefs.setString('translation_mode', TranslationMode.onDemand.toString());           //By default, on-demand translation is selected
        prefs.setString('translation_language', TranslationLanguage.english.toString());           //By default, translation to english is selected

        Fluttertoast.showToast(msg: "Sign in success");
        this.setState(() {
          isLoading = false;
        });


        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                currentUserId: firebaseUser.uid,
                prefs: this.prefs,
              )),
        );

      } else {
        // Write data to local
        prefs.setString('id', documents[0]['id']);
        prefs.setString('nickname', documents[0]['nickname']);
        prefs.setString('photoUrl', documents[0]['photoUrl']);
        prefs.setString('photosResolution', documents[0]['photosResolution']);
        prefs.setString('translation_mode', documents[0]['translation_mode'] ?? TranslationMode.onDemand);
        prefs.setString('translation_language', documents[0]['translation_language'] ?? TranslationLanguage.english);

        Fluttertoast.showToast(msg: "Sign in success");
        this.setState(() {
          isLoading = false;
        });

        if (documents[0]['nickname'].toString().length == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomeScreen(
                  currentUserId: firebaseUser.uid,
                  prefs: this.prefs,
                )),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainScreen(
                      currentUserId: firebaseUser.uid,
                      prefs: this.prefs,
                    )),
          );
        }
      }

    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
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

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
          onPressed: () => handleSignIn('email'),
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

    final GoogleLogin = Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: FlatButton(
          onPressed: () => handleSignIn('google'),
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
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen(prefs: this.prefs,)),
          );
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
              email,
              SizedBox(height: 8.0),
              password,
              SizedBox(height: 24.0),
              loginButton,
              GoogleLogin,
              registerButton,
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
