import 'package:meta/meta.dart';

enum ImageResolution {
  full, high, low
}

class Settings {

  final ImageResolution imageResolution;

  Settings({@required this.imageResolution});
}