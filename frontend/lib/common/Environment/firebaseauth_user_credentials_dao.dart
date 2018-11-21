import 'package:firebase_auth/firebase_auth.dart';

import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Models/query_entry.dart';
import 'package:chitchat/common/Models/signup_credentials.dart';

abstract class UserCredentialsDAOException extends DAOException {}

class EmailExistingException extends UserCredentialsDAOException {}

//Implements the DAO class with the concrete type SingupCredentials.
//Stores the given entities in Firebase by interacting with FirebaseAuth.
class FirebaseAuthUserCredentialsDAO implements DAO<SignupCredentials> {

  static FirebaseAuthUserCredentialsDAO _instance;

  //Singleton getter accessible as FirebaseAuthUserCredentialsDAO.shared
  static FirebaseAuthUserCredentialsDAO get shared {
    if (!FirebaseAuthUserCredentialsDAO._isInitialized()) {
      FirebaseAuthUserCredentialsDAO._initializeFields();
    }
    return FirebaseAuthUserCredentialsDAO._instance;
  }

  FirebaseAuth _firebaseAuthInstance;

  FirebaseAuthUserCredentialsDAO._private();

  static bool _isInitialized() {
    return FirebaseAuthUserCredentialsDAO._instance != null;
  }

  static void _initializeFields() {
    FirebaseAuthUserCredentialsDAO._instance = FirebaseAuthUserCredentialsDAO._private();
    FirebaseAuthUserCredentialsDAO._instance._firebaseAuthInstance = FirebaseAuth.instance;
  }

  //Singleton public methods

  //throws: EmailExistingException if trying to create a duplicate user (no existing email address can be used).
  @override
  Future<Object> create(SignupCredentials element, [bool forced=false]) async {
    if (forced) throw EmailExistingException();    //Cannot force saving a new user conflicting with a previous one, since there cannot be two users with the same email address.

    return await this._firebaseAuthInstance.createUserWithEmailAndPassword(email: element.email, password: element.password);
  }

  @override
  Future<Object> update(SignupCredentials element, [bool createIfNotExist=false]) {
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(Map<String, QueryEntry> filter) {
    throw UnimplementedError();
  }

  @override
  Future<SignupCredentials> get(Map<String, QueryEntry> filter) {
    throw UnimplementedError();
  }

  @override
  Future<List<SignupCredentials>> getAll(Map<String, QueryEntry> filter) {
    throw UnimplementedError();
  }
}