import 'package:chitchat/common/Models/signup_credentials.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SignUpManagerException implements Exception {}

abstract class SignUpManager<T> {

  Future<String> signUp(T credentials);
}

class UserCredentialsSignUpManager implements SignUpManager<SignupCredentials> {

  FirebaseAuth _firebaseAuthInstance;

  UserCredentialsSignUpManager._private();

  static UserCredentialsSignUpManager getInstance() {

    UserCredentialsSignUpManager instance = UserCredentialsSignUpManager._private();

    instance._firebaseAuthInstance = FirebaseAuth.instance;

    return instance;
  }

  @override
  Future<String> signUp(SignupCredentials credentials) async {

    FirebaseUser user = await this._firebaseAuthInstance.createUserWithEmailAndPassword(email: credentials.email, password: credentials.password);

    return user.uid;
  }

}