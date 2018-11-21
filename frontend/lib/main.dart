import 'package:chitchat/common/Environment/credentials_firebaseauth_sign_in_manager.dart';
import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Environment/firebase_picture_manager.dart';
import 'package:chitchat/common/Environment/firestore_user_profile_dao.dart';
import 'package:chitchat/common/Environment/google_firebaseauth_sign_in_manager.dart';
import 'package:chitchat/common/Environment/sign_up_manager.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:flutter/material.dart';

import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/my_app.dart';

//Asynchronously instantiates the needed managers/DAOs and starts the application.
Future<void> main() async {

  DAO<User> userProfileDAO = FirestoreUserProfileDAO.shared;

  Environment.setup(
    credentialsSignInManager: UserCredentialsFirebaseauthSignInManager.getInstance(userProfileDAO: userProfileDAO),
    googleSignInManager: GoogleFirebaseauthSignInManager.getInstance(userProfileDAO: userProfileDAO),
    credentialsSignUpManager: UserCredentialsSignUpManager.getInstance(),
    pictureManager: FirebasePictureManager.shared,
    userProfileDAO: userProfileDAO,
  );

  runApp(MyApp());
}