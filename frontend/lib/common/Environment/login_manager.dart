import 'package:chitchat/common/Models/user.dart';
import 'package:meta/meta.dart';

abstract class LoginManager {
  Future<bool> isUserLogged();
  Future<User> getUserLogged();
  Future<User> setUserLogged({@required User user, bool forced});
}