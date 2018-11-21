import 'package:chitchat/common/Models/user.dart';

abstract class SignInManager<T> {
  Future<User> signIn(T credentials);
  Future<void> signOut();
  Future<User> getSignedInUser();
  Future<bool> isUserSignedIn();
}