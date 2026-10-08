import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

String translateText(String text) {
  var sharedPreferences = Get.find<SharedPreferences>();
  String languageCode =
      sharedPreferences.getString(AppConstants.LANGUAGE_CODE) ?? 'en';

  final Map<String, Map<String, String>> numeralMaps = {
    // English (default for languages using standard Arabic numerals)
    'en': {
      '0': '0',
      '1': '1',
      '2': '2',
      '3': '3',
      '4': '4',
      '5': '5',
      '6': '6',
      '7': '7',
      '8': '8',
      '9': '9',
    },

    // Arabic, Persian, Urdu
    'ar': {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    },
    'fa': {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    },
    'ur': {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    },

    // Bengali
    'bn': {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    },

    // Devanagari (Hindi)
    'hi': {
      '0': '०',
      '1': '१',
      '2': '२',
      '3': '३',
      '4': '४',
      '5': '५',
      '6': '६',
      '7': '७',
      '8': '८',
      '9': '९',
    },

    // Thai
    'th': {
      '0': '๐',
      '1': '๑',
      '2': '๒',
      '3': '๓',
      '4': '๔',
      '5': '๕',
      '6': '๖',
      '7': '๗',
      '8': '๘',
      '9': '๙',
    },
  };

  String translatedText = text.replaceAllMapped(
    RegExp(r'[0-9]'),
    (match) {
      if (match.group(0) != null) {
        String digit = match.group(0)!;
        return numeralMaps[languageCode]?[digit] ?? digit;
      }
      return '';
    },
  );

  return translatedText;
}
