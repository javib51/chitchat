import 'dart:io';
import 'package:meta/meta.dart';

//Abstract class that must be implemented by all managers that deal with objects storing/retrieving.
abstract class PictureManager {

  //Saves the given picture to the storage with the given name.
  Future<Object> uploadPicture({@required File picture, String pictureName});
}