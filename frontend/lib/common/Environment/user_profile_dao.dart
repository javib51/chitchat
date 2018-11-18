import 'dart:convert';

import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Models/query_entry.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserProfileDAOException {
  userExistingException
}

class UserProfileDAO implements DAO<User> {

  UserProfileDAO._internal();

  static UserProfileDAO _instance;

  Firestore _firestoreInstance;
  FirebaseAuth _firebaseAuthInstance;

  //Singleton getter accessible as UserDAO.shared
  static UserProfileDAO get shared {
    if (!UserProfileDAO._isInitialized()) {
      UserProfileDAO._initializeFields();
    }
    return UserProfileDAO._instance;
  }

  static bool _isInitialized() {
    return UserProfileDAO._instance != null;
  }

  static void _initializeFields() {
    UserProfileDAO._instance = UserProfileDAO._internal();
    UserProfileDAO._instance._firestoreInstance = Firestore.instance;
    UserProfileDAO._instance._firebaseAuthInstance = FirebaseAuth.instance;
  }

  //Singleton public methods

  @override
  Future<Object> create(User element, [bool updateIfExist=false]) async {
    
    bool userProfileExists = (await this._getUserByID(element.uid)) != null;

    if (userProfileExists && !updateIfExist) throw UserProfileDAOException
        .userExistingException;

    await this._firestoreInstance.document(element.uid).setData({
      "nickname": element.nickname,
      "photoUrl": element.pictureURL,
      "id": element.uid,
      "aboutMe": element.aboutMe
    });

    return Future.value(null);
  }

  @override
  Future<void> update(User element, [bool createIfNotExist=false]) async {

    bool userProfileExists = (await this._getUserByID(element.uid)) != null;

    if (userProfileExists) {
      await this._firestoreInstance.document(element.uid).updateData({
        "nickname": element.nickname,
        "photoUrl": element.pictureURL,
        "id": element.uid,
        "aboutMe": element.aboutMe
      });
    } else {
      await this.create(element);
    }

    return Future.value(null);
  }

  @override
  Future<bool> delete(Map<String, QueryEntry> filter) {
    // TODO: implement delete
    return null;
  }

  //Map here should contain only the id key
  @override
  Future<User> get(Map<String, QueryEntry> filter) async {
    List<User> filteredQueryResult = await this.getAll(filter);

    if (filteredQueryResult.length > 1) throw DAOException.filterNotUniqueException;

    return filteredQueryResult[0];
  }

  Future<User> _getUserByID(String userID) async {
    return await this.get({"id": QueryEntry(value: userID, l: ValueComparisonLogic.e)});
  }

  @override
  Future<List<User>> getAll(Map<String, QueryEntry> filter) async {
    Query usersQuery = this._firestoreInstance.collection("users");
    
    filter.forEach((key, value) {
      usersQuery = this.getModifiedQueryForEntry(usersQuery, MapEntry(key, value));
    });

    List<DocumentSnapshot> queryResult = (await usersQuery.getDocuments()).documents;

    return queryResult.map((documentSnapshot) {
      return User(
          uid: documentSnapshot["id"],
          pictureURL: documentSnapshot["photoUrl"],
          nickname: documentSnapshot["nickname"],
          aboutMe: documentSnapshot["aboutMe"]
      );
    });
  }

  Query getModifiedQueryForEntry(Query q, MapEntry<String, QueryEntry> entry) {
    switch (entry.value.l) {
      case ValueComparisonLogic.e: {
        return q.where(entry.key, isEqualTo: entry.value);
      }
      case ValueComparisonLogic.ge: {
        return q.where(entry.key, isGreaterThanOrEqualTo: entry.value);
      }
      case ValueComparisonLogic.gt: {
        return q.where(entry.key, isGreaterThan: entry.value);
      }
      case ValueComparisonLogic.le: {
        return q.where(entry.key, isLessThanOrEqualTo: entry.value);
      }
      case ValueComparisonLogic.lt: {
        return q.where(entry.key, isLessThan: entry.value);
      }
      case ValueComparisonLogic.n: {
        return q.where(entry.key, isNull: true);
      }
      case ValueComparisonLogic.nn: {
        return q.where(entry.key, isNull: false);
      }
      default: {      //Never reached since we are checking an enum
        return null;
      }
    }
  }
}