import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Environment/login_manager.dart';
import 'package:chitchat/common/Environment/storage_manager.dart';
import 'package:meta/meta.dart';

class Environment {

  Environment._internal();

  static Environment _instance;

  LoginManager loginManager;
  StorageManager storageManager;
  DAO userProfileDAO;
  DAO userCredentialsDAO;

  //Must be called at least once before using the Environment anywhere across the app.
  static void setup({@required LoginManager loginManager, @required StorageManager storageManager, @required DAO userProfileDAO, @required DAO userCredentialsDAO}) {
    if (Environment._instance == null) {
      Environment._instance = Environment._internal();
    }
    Environment._instance.loginManager = loginManager;
    Environment._instance.userProfileDAO= userProfileDAO;
    Environment._instance.userCredentialsDAO = userCredentialsDAO;
  }

  static Environment get shared {
    return Environment._instance;
  }
}