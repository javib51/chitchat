import 'package:chitchat/common/Environment/sign_in_manager.dart';
import 'package:chitchat/common/Environment/sign_up_manager.dart';
import 'package:chitchat/common/Models/google_credentials.dart';
import 'package:chitchat/common/Models/signup_credentials.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:meta/meta.dart';

import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Environment/storage_manager.dart';

//Singleton class that contains all the managers the app needs during its lifetime.
//Initialized at launch time and accessible for the whole execution time.
class Environment {

  static Environment _instance;

  //static getter to get the singleton instance
  static Environment get shared => Environment._instance;


  PictureManager _pictureManager;      //Manager to interact with storing objects somewhere
  PictureManager get pictureManager => this._pictureManager;

  DAO<User> _userProfileDAO;                 //Manager to CRUD user profiles
  DAO<User> get userProfileDAO => this._userProfileDAO;

  SignInManager<SignupCredentials> _credentialsSignInManager;             //Manager for sign in operations with classic credentials (email, password)
  SignInManager<SignupCredentials> get credentialsSignInManager => this._credentialsSignInManager;

  SignInManager<GoogleCredentials> _googleSignInManager;
  SignInManager<GoogleCredentials> get googleSignInManager => this.googleSignInManager;

  SignUpManager<SignupCredentials> _credentialsSignUpManager;
  SignUpManager<SignupCredentials> get credentialsSignUpManager => this._credentialsSignUpManager;

  Environment._private();

  //Must be called at least once before using the Environment anywhere across the app.
  static void setup({
    @required PictureManager pictureManager,
    @required DAO<User> userProfileDAO,
    @required SignInManager<SignupCredentials> credentialsSignInManager,
    @required SignInManager<GoogleCredentials> googleSignInManager,
    @required SignUpManager<SignupCredentials> credentialsSignUpManager,
  }) {

    Environment instance = Environment._instance ?? Environment._private();

    instance._pictureManager = pictureManager;
    instance._userProfileDAO = userProfileDAO;
    instance._credentialsSignInManager = credentialsSignInManager;
    instance._googleSignInManager = googleSignInManager;
    instance._credentialsSignUpManager = credentialsSignUpManager;

    Environment._instance = instance;
  }
}