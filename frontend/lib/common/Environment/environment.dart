import 'package:meta/meta.dart';

import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Environment/login_manager.dart';
import 'package:chitchat/common/Environment/storage_manager.dart';

//Singleton class that contains all the managers the app needs during its lifetime.
//Initialized at launch time and accessible for the whole execution time.
class Environment {

  static Environment _instance;

  //static getter to get the singleton instance
  static Environment get shared => Environment._instance;

  LoginManager _loginManager;          //Manager to interact with login/logout related actions
  LoginManager get loginManager => this._loginManager;

  StorageManager _storageManager;      //Manager to interact with storing objects somewhere
  StorageManager get storageManager => this._storageManager;

  DAO _userProfileDAO;                 //Manager to CRUD user profiles
  DAO get userProfileDAO => this._userProfileDAO;

  DAO _userCredentialsDAO;             //Manager to CRUD user signups
  DAO get userCredentialsDAO => this._userCredentialsDAO;

  Environment._private();

  //Must be called at least once before using the Environment anywhere across the app.
  static void setup({@required LoginManager loginManager, @required StorageManager storageManager, @required DAO userProfileDAO, @required DAO userCredentialsDAO}) {

    Environment instance = Environment._instance ?? Environment._private();

    instance._loginManager = loginManager;
    instance._userProfileDAO= userProfileDAO;
    instance._userCredentialsDAO = userCredentialsDAO;

    Environment._instance = instance;
  }
}