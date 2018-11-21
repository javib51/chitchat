import 'package:flutter/material.dart';

import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/common/Environment/firebase_storage_manager.dart';
import 'package:chitchat/common/Environment/local_storage_login_manager.dart';
import 'package:chitchat/common/Environment/firebaseauth_user_credentials_dao.dart';
import 'package:chitchat/common/Environment/firestore_user_profile_dao.dart';
import 'package:chitchat/my_app.dart';

//Asynchronously instantiates the needed managers/DAOs and starts the application.
Future<void> main() async {

  Environment.setup(
    loginManager: await LocalStorageLoginManager.shared,
    storageManager: await FirebaseStorageManager.shared,
    userCredentialsDAO: FirebaseAuthUserCredentialsDAO.shared,
    userProfileDAO: FirestoreUserProfileDAO.shared,
  );
  runApp(MyApp());
}