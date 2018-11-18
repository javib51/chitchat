import 'package:codable/codable.dart';

class SignupCredentials extends Coding {
  String email;
  String password;

  SignupCredentials({this.email, this.password});

  @override
  void encode(KeyedArchive object) {
    object.encode("user_email", this.email);
    object.encode("user_password", this.password);
  }

  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    this.email = object.decode("user_email");
    this.password = object.decode("user_password");
  }
}