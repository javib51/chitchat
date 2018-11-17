import 'package:chitchat/common/Environment/login_manager.dart';
import 'package:meta/meta.dart';

class Environment {

  Environment._internal();

  static Environment _instance;

  LoginManager loginManager;

  static Environment get shared {
    return Environment._instance;
  }

  //Must be called at least once before using the Environment anywhere across the app.
  static void setup({@required LoginManager loginManager}) {
    if (Environment._instance == null) {
      Environment._instance = Environment._internal();
    }
    Environment._instance.loginManager = loginManager;
  }
}