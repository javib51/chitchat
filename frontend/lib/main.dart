import 'package:chitchat/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {

  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs,));
}