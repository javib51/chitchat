enum TranslationMode {
  automatic, onDemand
}

TranslationMode getTranslationModeFromString(String stringValue) {
  if (stringValue == TranslationMode.automatic.toString()) return TranslationMode.automatic;
  else if (stringValue == TranslationMode.onDemand.toString()) return TranslationMode.onDemand;
  else return null;
}

String getTranslationModeUsableString(TranslationMode translationMode) {
  switch (translationMode) {
    case TranslationMode.onDemand: { return "On demand"; } break;
    case TranslationMode.automatic: { return "Automatic"; } break;
    default: return null;
  }
}


enum TranslationLanguage {
  english, italian, spanish, german, finnish, french, portuguese
}

TranslationLanguage getTranslationLanguageFromString(String stringValue) {
  if (stringValue == TranslationLanguage.english.toString()) return TranslationLanguage.english;
  else if (stringValue == TranslationLanguage.italian.toString()) return TranslationLanguage.italian;
  else if (stringValue == TranslationLanguage.spanish.toString()) return TranslationLanguage.spanish;
  else if (stringValue == TranslationLanguage.german.toString()) return TranslationLanguage.german;
  else if (stringValue == TranslationLanguage.finnish.toString()) return TranslationLanguage.finnish;
  else if (stringValue == TranslationLanguage.french.toString()) return TranslationLanguage.french;
  else if (stringValue == TranslationLanguage.portuguese.toString()) return TranslationLanguage.portuguese;
  else return null;
}

String getCountryISOCode(TranslationLanguage language) {
  switch (language) {
    case TranslationLanguage.portuguese: return "pt"; break;
    case TranslationLanguage.french: return "fr"; break;
    case TranslationLanguage.finnish: return "fi"; break;
    case TranslationLanguage.german: return "de"; break;
    case TranslationLanguage.spanish: return "es"; break;
    case TranslationLanguage.italian: return "it"; break;
    case TranslationLanguage.english: return "en"; break;
    default: return null;
  }
}

String getTranslationLanguageUsableString(TranslationLanguage language) {

  String flag;
  String languageStringValue = language.toString().split(".").last;

  switch (language) {
    case TranslationLanguage.portuguese: flag = "🇵🇹"; break;
    case TranslationLanguage.french: flag = "🇫🇷"; break;
    case TranslationLanguage.finnish: flag = "🇫🇮"; break;
    case TranslationLanguage.german: flag = "🇩🇪"; break;
    case TranslationLanguage.spanish: flag = "🇪🇸"; break;
    case TranslationLanguage.italian: flag = "🇮🇹"; break;
    case TranslationLanguage.english: flag = "🇺🇸🇬🇧"; break;
    default: return null;
  }

  return "$flag ${languageStringValue[0].toUpperCase()}${languageStringValue.substring(1)}";
}