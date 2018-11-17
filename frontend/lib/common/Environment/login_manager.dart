import 'package:chitchat/common/Models/user.dart';
import 'package:meta/meta.dart';

abstract class LoginManager {
  bool isUserLogged();
  User getUserLogged();
  User saveUser({@required User user, bool forced});
}