import 'package:meta/meta.dart';

import 'package:chitchat/common/Models/user.dart';

abstract class LoginManagerException implements Exception {}

class UserExistingException extends LoginManagerException {}

enum LoginOption {
  google,
  regular
}

//Abstract class providing an interface to all login/logout related actions.
abstract class LoginManager {

  //Returns true if there is an active login session saved on the device. False otherwise.
  bool isUserLogged();

  //Returns the logged-in user that has been saved locally. Null otherwise.
  User getUserLogged();

  //Sets a new login session on the device associated with the given user. Returns the existing user if it has been overriden by the new one.
  //forced: if the existing user should be overridden by the new one or not.

  //throws: LoginManagerException if forced is false and there is already an user saved.
  User setUserLogged({@required User user, bool forced});
}