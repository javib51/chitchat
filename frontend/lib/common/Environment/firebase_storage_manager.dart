import 'dart:io';

import 'package:chitchat/common/Environment/storage_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

class FirebaseStorageManager implements StorageManager {

  FirebaseStorageManager._internal();

  static FirebaseStorageManager _instance;

  FirebaseStorage _storage;

  //Singleton getter accessible as LocalStorageLoginManager.shared
  static Future<FirebaseStorageManager> get shared async {
    if (!FirebaseStorageManager._isInitialized()) {
      await FirebaseStorageManager._initializeFields();
    }
    return FirebaseStorageManager._instance;
  }

  static bool _isInitialized() {
    return FirebaseStorageManager._instance != null;
  }

  static Future<void> _initializeFields() async {
    FirebaseStorageManager._instance = FirebaseStorageManager._internal();
    FirebaseStorageManager._instance._storage = FirebaseStorage.instance;
  }

  //Singleton public methods

  @override
  Future<T> uploadProfilePicture<T>({@required File profilePicture, String fileName}) async {
    StorageReference reference = this._storage.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(profilePicture);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    return await storageTaskSnapshot.ref.getDownloadURL();
  }
}
