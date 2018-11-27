enum ImageResolutionType {
  low,
  high,
  full
}

class ImageResolution {

  final ImageResolutionType _type;

  String get settingsName {
    switch (this._type) {
      case ImageResolutionType.low:
        return "low";
      case ImageResolutionType.high:
        return "high";
      case ImageResolutionType.full:
        return "full";
      default:
        return "invalid";     //Never gets here
    }

  }

  ImageResolution(this._type);
}