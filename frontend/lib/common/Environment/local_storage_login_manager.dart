import 'dart:convert';

import 'package:chitchat/common/Environment/login_manager.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:codable/codable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageLoginManager implements LoginManager {

  LocalStorageLoginManager._internal();

  static LocalStorageLoginManager _instance;

  SharedPreferences _prefs;

  //Singleton getter accessible as LocalStorageLoginManager.shared
  static Future<LocalStorageLoginManager> get shared async {
    if (!LocalStorageLoginManager._isInitialized()) {
      await LocalStorageLoginManager._initializeFields();
    }
    return LocalStorageLoginManager._instance;
  }

  static bool _isInitialized() {
    return LocalStorageLoginManager._instance != null;
  }

  static Future<void> _initializeFields() async {
    LocalStorageLoginManager._instance = LocalStorageLoginManager._internal();
    LocalStorageLoginManager._instance._prefs = await SharedPreferences.getInstance();
  }

  //Singleton public methods

  Future<bool> isUserLogged() async {
    return this._prefs.getString("user_id") != null;
  }

  Future<User> getUserLogged() async {

    var existingUser = this._prefs.get("user");

    if (existingUser == null) return null;

    return User()..decode(KeyedArchive.unarchive(json.decode(existingUser)));
  }

  Future<User> setUserLogged({@required User user, bool forced}) async {

    var existingUser = this._prefs.get("user");

    if (existingUser != null && !forced) return null;

    this._prefs.setString("user", json.encode(KeyedArchive.archive(existingUser)));

    if (existingUser == null) return null;
    return User()..decode(KeyedArchive.unarchive(json.decode(existingUser)));
  }
}
