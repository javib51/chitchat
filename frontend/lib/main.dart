import 'package:chitchat/common/Environment/environment.dart';
import 'package:chitchat/common/Environment/local_storage_login_manager.dart';
import 'package:chitchat/my_app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  Environment.setup(loginManager: await LocalStorageLoginManager.shared,);
  runApp(MyApp());
}