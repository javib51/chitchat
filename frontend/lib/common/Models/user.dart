import 'package:codable/codable.dart';

class User extends Coding implements Comparable<User> {

  String _uid;
  String get uid => this._uid;

  String _nickname;
  String get nickname => this._nickname;

  String _aboutMe;
  String get aboutMe => this._aboutMe;

  String _pictureURL;
  String get pictureURL => this._pictureURL;

  User({String uid, String nickname, String aboutMe, String pictureURL}) {
    this._uid = uid;
    this._nickname = nickname;
    this._aboutMe = aboutMe;
    this._pictureURL = pictureURL;
  }

  @override
  void encode(KeyedArchive object) {
    object.encode("user_id", this._uid);
    object.encode("user_nickname", this._nickname);
    object.encode("user_about", this._aboutMe);
    object.encode("user_picture_url", this._pictureURL);
  }

  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    this._uid = object.decode("user_id");
    this._nickname = object.decode("user_nickname");
    this._aboutMe = object.decode("user_about");
    this._pictureURL = object.decode("user_picture_url");
  }

  @override
  int compareTo(User other) {
    return this.uid.compareTo(other.uid);
  }
}