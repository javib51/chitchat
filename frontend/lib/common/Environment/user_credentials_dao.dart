import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Models/query_entry.dart';
import 'package:chitchat/common/Models/signup_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserCredentialsDAOException {
  requiredFilterParameterMissing,
  emailExistingException,
  wrongCommandException
}

class UserCredentialsDAO implements DAO<SignupCredentials> {

  UserCredentialsDAO._internal();

  static UserCredentialsDAO _instance;

  Firestore _firestoreInstance;
  FirebaseAuth _firebaseAuthInstance;

  //Singleton getter accessible as UserDAO.shared
  static UserCredentialsDAO get shared {
    if (!UserCredentialsDAO._isInitialized()) {
      UserCredentialsDAO._initializeFields();
    }
    return UserCredentialsDAO._instance;
  }

  static bool _isInitialized() {
    return UserCredentialsDAO._instance != null;
  }

  static void _initializeFields() {
    UserCredentialsDAO._instance = UserCredentialsDAO._internal();
    UserCredentialsDAO._instance._firestoreInstance = Firestore.instance;
    UserCredentialsDAO._instance._firebaseAuthInstance = FirebaseAuth.instance;
  }

  @override
  Future<Object> create(SignupCredentials element, [bool forced=false]) async {
    if (forced) throw UserCredentialsDAOException.wrongCommandException;    //Cannot force saving a new user conflicting with a previous one.

    return await this._firebaseAuthInstance.createUserWithEmailAndPassword(email: element.email, password: element.password);
  }

  @override
  Future<void> update(SignupCredentials element, [bool createIfNotExist=false]) {
    // TODO: implement delete
    return null;
  }

  @override
  Future<bool> delete(Map<String, QueryEntry> filter) {
    // TODO: implement delete
    return null;
  }

  @override
  //Use of `email` key for searching by email.
  Future<SignupCredentials> get(Map<String, QueryEntry> filter) {
    // TODO: implement get
    return null;
  }

  @override
  Future<List<SignupCredentials>> getAll(Map<String, QueryEntry> filter) {
    // TODO: implement getAll
    return null;
  }
}