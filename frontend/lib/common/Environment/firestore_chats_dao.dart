import 'package:chitchat/common/Models/chat.dart';
import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Models/message.dart';
import 'package:chitchat/common/Models/query_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatsDAOException extends DAOException {}

class ChatExistingException extends ChatsDAOException {}

//Implements the DAO class with the concrete type User.
//Stores the given entities in Firestore database.
class FirestoreChatsDAO implements DAO<Chat> {

  static FirestoreChatsDAO _instance;

  //Singleton getter accessible as FirestoreUserProfileDAO.shared
  static FirestoreChatsDAO get shared {
    if (!FirestoreChatsDAO._isInitialized()) {
      FirestoreChatsDAO._initializeFields();
    }
    return FirestoreChatsDAO._instance;
  }

  Firestore _firestoreInstance;

  FirestoreChatsDAO._private();

  static bool _isInitialized() {
    return FirestoreChatsDAO._instance != null;
  }

  static void _initializeFields() {
    FirestoreChatsDAO._instance = FirestoreChatsDAO._private();
    FirestoreChatsDAO._instance._firestoreInstance = Firestore.instance;
  }

  //Singleton public methods

  //throws: UserExistingException if trying to create a duplicate user.
  @override
  Future<Object> create(Chat element, [bool updateIfExist=false]) async {

    bool chatExists = (await this._getChatByID(element.id)) != null;

    print("chatExists? $chatExists");

    if (chatExists && !updateIfExist) throw ChatExistingException();
    else if (chatExists) {
      print("Updating existing chat");
      await this.update(element, false);
    } else {
      print("Creating new chat");

      DocumentReference newChatReference = this._firestoreInstance.collection("chats").document(element.id);

      await newChatReference.setData(element.getTopLevelFirestoreStructure());

      element.getNestedFirestoreCollections().forEach((collectionName, collectionValue) async {
        CollectionReference nestedCollectionReference = newChatReference.collection(collectionName);
        collectionValue.forEach((collectionEntry) async {
          DocumentReference nestedDocumentReference = nestedCollectionReference.document(collectionEntry.key);
          await nestedDocumentReference.setData(collectionEntry.value);
        });
      });

      print("Created new chat");
    }

    return Future.value(null);
  }

  @override
  Future<void> update(Chat element, [bool createIfNotExist=false]) async {

    bool chatExists = (await this._getChatByID(element.id)) != null;

    if (chatExists) {

      DocumentReference newChatReference = this._firestoreInstance.collection("chats").document(element.id);

      await newChatReference.updateData(element.getTopLevelFirestoreStructure());

      element.getNestedFirestoreCollections().forEach((collectionName, collectionValue) async {
        CollectionReference nestedCollectionReference = newChatReference.collection(collectionName);
        collectionValue.forEach((collectionEntry) async {
          DocumentReference nestedDocumentReference = nestedCollectionReference.document(collectionEntry.key);
          await nestedDocumentReference.update(collectionEntry.value);
        });
      });
    } else {
      await this.create(element);
    }

    return Future.value(null);
  }

  Future<Chat> _getChatByID(String chatID) async {
    return await this.get({"id": QueryEntry(comparisonValue: chatID, l: ValueComparisonLogic.e)});
  }

  @override
  Future<bool> delete(Map<String, QueryEntry> filter) {
    throw UnimplementedError();
  }

  @override
  Future<Chat> get<T>(Map<String, QueryEntry<T>> filter) async {
    List<Chat> filteredQueryResult = await this.getAll(filter);

    print(filteredQueryResult);

    if (filteredQueryResult.length > 1) throw FilterNotUniqueException();

    return filteredQueryResult.isEmpty ? null : filteredQueryResult.elementAt(0);
  }

  @override
  Future<List<Chat>> getAll(Map<String, QueryEntry> filter) async {
    Query chatsQuery = this._firestoreInstance.collection("chats");

    filter.forEach((key, value) {
      chatsQuery = this._getModifiedQueryForEntry(chatsQuery, MapEntry(key, value));
    });

    List<DocumentSnapshot> queryResult = (await chatsQuery.getDocuments()).documents;

    return queryResult.map((documentSnapshot) {

      String chatID = documentSnapshot["id"];
      List<Message> chatMessages = documentSnapshot["messages"];
      String chatType = documentSnapshot["type"];

      if (chatType == "G") {
        return GroupChat(
          id: chatID,
          messages: chatMessages,
          participantsIDs:
        )
      }

      return Chat(
        id: documentSnapshot["id"],
        messages: documentSnapshot["messages"],

//          uid: documentSnapshot["id"],
//          pictureURL: documentSnapshot["photoUrl"],
//          nickname: documentSnapshot["nickname"],
//          aboutMe: documentSnapshot["aboutMe"]
      );
    }).toList(growable: false);
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