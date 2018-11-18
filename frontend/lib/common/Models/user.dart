import 'package:codable/codable.dart';

class User extends Coding {
  String uid;
  String nickname;
  String aboutMe;
  String pictureURL;

  User({this.uid, this.nickname, this.pictureURL, this.aboutMe});

  @override
  void encode(KeyedArchive object) {
    object.encode("user_id", this.uid);
    object.encode("user_nickname", this.nickname);
    object.encode("user_about", this.aboutMe);
    object.encode("user_picture_url", this.pictureURL);
  }

  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    this.uid = object.decode("user_id");
    this.nickname = object.decode("user_nickname");
    this.aboutMe = object.decode("user_about");
    this.pictureURL = object.decode("user_picture_url");
  }
}