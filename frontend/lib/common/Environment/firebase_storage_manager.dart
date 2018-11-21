import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

import 'package:chitchat/common/Environment/storage_manager.dart';

//Implements the StorageManager class.
//Stores the given entities in Firebase Storage.
class FirebaseStorageManager implements StorageManager {

  static FirebaseStorageManager _instance;

  static Future<FirebaseStorageManager> get shared async {
    if (!FirebaseStorageManager._isInitialized()) {
      await FirebaseStorageManager._initializeFields();
    }
    return FirebaseStorageManager._instance;
  }

  FirebaseStorage _storage;

  FirebaseStorageManager._private();

  static bool _isInitialized() {
    return FirebaseStorageManager._instance != null;
  }

  static Future<void> _initializeFields() async {
    FirebaseStorageManager._instance = FirebaseStorageManager._private();
    FirebaseStorageManager._instance._storage = FirebaseStorage.instance;
  }

  //Singleton public methods

  @override
  Future<Object> uploadPicture({@required File picture, String pictureName}) async {
    StorageReference reference = this._storage.ref().child(pictureName);
    StorageUploadTask uploadTask = reference.putFile(picture);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    return await storageTaskSnapshot.ref.getDownloadURL();
  }
}
