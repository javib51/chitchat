import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Models/query_entry.dart';
import 'package:chitchat/common/Models/user.dart';

enum UserProfileDAOException {
  userExistingException
}

//Implements the DAO class with the concrete type User.
//Stores the given entities in Firestore database.
class FirestoreUserProfileDAO implements DAO<User> {

  static FirestoreUserProfileDAO _instance;

  //Singleton getter accessible as FirestoreUserProfileDAO.shared
  static FirestoreUserProfileDAO get shared {
    if (!FirestoreUserProfileDAO._isInitialized()) {
      FirestoreUserProfileDAO._initializeFields();
    }
    return FirestoreUserProfileDAO._instance;
  }

  Firestore _firestoreInstance;

  FirestoreUserProfileDAO._internal();

  static bool _isInitialized() {
    return FirestoreUserProfileDAO._instance != null;
  }

  static void _initializeFields() {
    FirestoreUserProfileDAO._instance = FirestoreUserProfileDAO._internal();
    FirestoreUserProfileDAO._instance._firestoreInstance = Firestore.instance;
  }

  //Singleton public methods

  //throws: UserProfileDAOException.userExistingException if trying to create a duplicate user.
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

  Future<User> _getUserByID(String userID) async {
    return await this.get({"id": QueryEntry(comparisonValue: userID, l: ValueComparisonLogic.e)});
  }

  @override
  Future<bool> delete(Map<String, QueryEntry> filter) {
    throw UnimplementedError();
  }

  @override
  Future<User> get(Map<String, QueryEntry> filter) async {
    List<User> filteredQueryResult = await this.getAll(filter);

    if (filteredQueryResult.length > 1) throw DAOException.filterNotUniqueException;

    return filteredQueryResult[0];
  }

  @override
  Future<List<User>> getAll(Map<String, QueryEntry> filter) async {
    Query usersQuery = this._firestoreInstance.collection("users");

    filter.forEach((key, value) {
      usersQuery = this._getModifiedQueryForEntry(usersQuery, MapEntry(key, value));
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

  Query _getModifiedQueryForEntry(Query q, MapEntry<String, QueryEntry> entry) {
    switch (entry.value.l) {
      case ValueComparisonLogic.e: {
        return q.where(entry.key, isEqualTo: entry.value.comparisonValue);
      }
      case ValueComparisonLogic.ge: {
        return q.where(entry.key, isGreaterThanOrEqualTo: entry.value.comparisonValue);
      }
      case ValueComparisonLogic.gt: {
        return q.where(entry.key, isGreaterThan: entry.value.comparisonValue);
      }
      case ValueComparisonLogic.le: {
        return q.where(entry.key, isLessThanOrEqualTo: entry.value.comparisonValue);
      }
      case ValueComparisonLogic.lt: {
        return q.where(entry.key, isLessThan: entry.value.comparisonValue);
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