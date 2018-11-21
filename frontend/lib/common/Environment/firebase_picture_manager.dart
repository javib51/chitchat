import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

import 'package:chitchat/common/Environment/storage_manager.dart';

//Implements the StorageManager class.
//Stores the given entities in Firebase Storage.
class FirebasePictureManager implements PictureManager {

  static FirebasePictureManager _instance;

  static FirebasePictureManager get shared {
    if (!FirebasePictureManager._isInitialized()) {
      FirebasePictureManager._initializeFields();
    }
    return FirebasePictureManager._instance;
  }

  FirebaseStorage _storage;

  FirebasePictureManager._private();

  static bool _isInitialized() {
    return FirebasePictureManager._instance != null;
  }

  static _initializeFields() {
    FirebasePictureManager._instance = FirebasePictureManager._private();
    FirebasePictureManager._instance._storage = FirebaseStorage.instance;
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
