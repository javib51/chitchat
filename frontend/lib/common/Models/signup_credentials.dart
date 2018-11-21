import 'package:codable/codable.dart';
import 'package:meta/meta.dart';

//Entity representing a user credential.
class SignupCredentials extends Coding {

  String _email;
  String get email => this.email;

  String _password;
  String get password => this._password;

  SignupCredentials({@required String email, @required String password}) {
    this._email = email;
    this._password = password;
  }

  @override
  void encode(KeyedArchive object) {
    object.encode("user_email", this._email);
    object.encode("user_password", this._password);
  }

  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    this._email = object.decode("user_email");
    this._password = object.decode("user_password");
  }
}