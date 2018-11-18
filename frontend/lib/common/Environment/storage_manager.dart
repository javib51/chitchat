import 'dart:io';
import 'package:meta/meta.dart';

abstract class StorageManager {
  Future<T> uploadProfilePicture<T>({@required File profilePicture, String fileName});
}