import 'package:chitchat/common/Environment/firestore_compatible.dart';
import 'package:chitchat/common/Environment/image_resolution.dart';
import 'package:codable/codable.dart';

class User extends Coding implements Comparable<User>, FirestoreCompatible<User> {

  String _uid;
  String get uid => this._uid;

  String _nickname;
  String get nickname => this._nickname;

  String _aboutMe;
  String get aboutMe => this._aboutMe;

  String _pictureURL;
  String get pictureURL => this._pictureURL;

  String _notificationToken;
  String get notificationToken => this._notificationToken;

  ImageResolution _imageRes;
  ImageResolution get imageRes => this._imageRes;

  User({String uid, String nickname, String aboutMe, String pictureURL, String notificationToken, ImageResolution imageRes}) {
    this._uid = uid;
    this._nickname = nickname;
    this._aboutMe = aboutMe;
    this._pictureURL = pictureURL;
    this._notificationToken = notificationToken;
    this._imageRes = imageRes;
  }

  @override
  void encode(KeyedArchive object) {
    object.encode("user_id", this._uid);
    object.encode("user_nickname", this._nickname);
    object.encode("user_about", this._aboutMe);
    object.encode("user_picture_url", this._pictureURL);
    object.encode("notification_token", this._notificationToken);
    object.encode("image_resolution", this._imageRes);
  }

  @override
  void decode(KeyedArchive object) {
    super.decode(object);
    this._uid = object.decode("user_id");
    this._nickname = object.decode("user_nickname");
    this._aboutMe = object.decode("user_about");
    this._pictureURL = object.decode("user_picture_url");
    this._notificationToken = object.decode("notification_token");
    this._imageRes = object.decode("image_resolution");
  }

  @override
  int compareTo(User other) {
    return this.uid.compareTo(other.uid);
  }

  @override
  Map<String, dynamic> getFirestoreStructure(User element) {
    return {
      "nickname": element.nickname,
      "photoUrl": element.pictureURL,
      "id": element.uid,
      "aboutMe": element.aboutMe,
      "notificationToken": element.notificationToken,
      "imageResolution": element.imageRes
    };
  }
}