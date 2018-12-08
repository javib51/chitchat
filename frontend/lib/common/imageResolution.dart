enum ImageResolution {
 low, high, full
}

String getPrefix(ImageResolution localSettingMaxResolution, ImageResolution pictureMaxResolution) {

  int comparisonResult = _compare(localSettingMaxResolution, pictureMaxResolution);

  if (comparisonResult == 0) {
    //The image will be named exactly like this, since it means that the uploaded image reflects this client.
    return "";
  } else if (comparisonResult == 1) {
    //This client expects a higher picture, but cannot get it, so still the name of the image will not be modified;
    return "";
  } else {
    //This client cannot download the picture as defined there, so it has to ask for a smaller one.
    return localSettingMaxResolution == ImageResolution.low ? "thumb_640_480_" : "thumb_1280_960_";     //ImageResolution.full is impossbile since the comparison result not be -1.
  }
}

//ImageResolution getRightResolutionToDownload(ImageResolution localSettingMaxResolution, ImageResolution pictureMaxResolution) {
//  int comparisonResult = _compare(localSettingMaxResolution, pictureMaxResolution);
//
//  if (comparisonResult <= 0) {       //remote max resolution >= local max resolution
//    return localSettingMaxResolution;
//  } else {                           //local max resolution > remote max resolution
//    return pictureMaxResolution;
//  }
//}

ImageResolution getEnumFromString(String stringValue) {
  if (stringValue == ImageResolution.full.toString() || stringValue == ImageResolution.full.toString().split(".").last) {
    return ImageResolution.full;
  } else if (stringValue == ImageResolution.high.toString() || stringValue == ImageResolution.high.toString().split(".").last) {
    return ImageResolution.high;
  } else if (stringValue == ImageResolution.low.toString() || stringValue == ImageResolution.low.toString().split(".").last) {
    return ImageResolution.low;
  } else {
    return null;
  }
}

int _compare(ImageResolution res1, ImageResolution res2) {
  if (res1 == ImageResolution.full) {
    return res2 == ImageResolution.full ? 0 : 1;
  } else if (res1 == ImageResolution.high) {
    return res2 == ImageResolution.high ? 0 : res2 == ImageResolution.full ? -1 : 1;
  } else if (res1 == ImageResolution.low) {
    return res2 == ImageResolution.low ? 0 : -1;
  }
}