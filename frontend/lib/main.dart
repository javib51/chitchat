import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/common/Environment/firebase_storage_manager.dart';
import 'package:chitchat/common/Environment/local_storage_login_manager.dart';
import 'package:chitchat/common/Environment/user_credentials_dao.dart';
import 'package:chitchat/common/Environment/user_profile_dao.dart';
import 'package:chitchat/my_app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  Environment.setup(
    loginManager: await LocalStorageLoginManager.shared,
    storageManager: await FirebaseStorageManager.shared,
    userCredentialsDAO: UserCredentialsDAO.shared,
    userProfileDAO: UserProfileDAO.shared,
  );
  runApp(MyApp());
}