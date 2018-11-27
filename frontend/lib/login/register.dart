<<<<<<< HEAD
import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/common/Environment/sign_in_manager.dart';
import 'package:chitchat/common/Environment/sign_up_manager.dart';
import 'package:chitchat/common/Models/signup_credentials.dart';
import 'package:chitchat/common/Models/user.dart';
=======
import 'package:chitchat/const.dart';
>>>>>>> 83e4b079478b8ea2e192d33679414099c7d95982
import 'package:chitchat/login/welcome.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {

  @override
  _RegisterScreenState createState() => new _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _emailController = TextEditingController();
  final _passController = TextEditingController();

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
=======
    await prefs.clear();
    await prefs.setString('id', firebaseUser.uid);
    await prefs.setString('photoUrl', "https://www.simplyweight.co.uk/images/default/chat/mck-icon-user.png");
>>>>>>> 83e4b079478b8ea2e192d33679414099c7d95982

    final formFieldDecoration = (String hint) => InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0)
    );

    final emailFormField = TextFormField(
      controller: this._emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: formFieldDecoration("Email"),
    );

    final passwordFormField = TextFormField(
      controller: this._passController,
      autofocus: false,
      obscureText: true,
      decoration: formFieldDecoration("Password"),
    );

    final registerButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
          onPressed: this.handleRegister,
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
<<<<<<< HEAD
            ),
            SizedBox(height: 40.0),
            emailFormField,
            SizedBox(height: 8.0),
            passwordFormField,
            SizedBox(height: 24.0),
            registerButton,
            loginButton
          ],
=======
              SizedBox(height: 40.0),
              email,
              SizedBox(height: 8.0),
              password,
              SizedBox(height: 24.0),
              registerButton,
              loginButton
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

  Future<Null> handleRegister() async {

    if (this._emailController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please provide email");
      return;
    }

    if (this._passController.text.length < 6) {
      Fluttertoast.showToast(msg: "Minimal password length is 6");
      return;
    }

    SignUpManager<SignupCredentials> signUpManager = Environment.shared.credentialsSignUpManager;
    SignInManager<SignupCredentials> signInManager = Environment.shared.credentialsSignInManager;
    DAO<User> userprofileDAO = Environment.shared.userProfileDAO;

    try {
      SignupCredentials credentials = SignupCredentials(
          email: this._emailController.text.trim(),
          password: this._passController.text.trim());

      String newUserID = await signUpManager.signUp(credentials);
      print(newUserID);
      await userprofileDAO.create(User(uid: newUserID));
      await signInManager.signIn(credentials);
    } catch (e) {
      Fluttertoast.showToast(msg: "Registration failed: ${e.toString()}");
      print(e);
      return;
    }

    Fluttertoast.showToast(msg: "Registration succeeded");

    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
  }
}
