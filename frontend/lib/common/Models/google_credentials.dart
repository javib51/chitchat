//Entity representing Google login credentials
import 'package:meta/meta.dart';

class GoogleCredentials {

  String _accessToken;
  String get accessToken => this._accessToken;

  String _idToken;
  String get idToken => this._idToken;

  GoogleCredentials({@required String accessToken, @required String idToken}) {
    this._accessToken = accessToken;
    this._idToken = idToken;
  }
}