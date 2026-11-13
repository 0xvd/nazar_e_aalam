// ignore_for_file: constant_identifier_name, constant_identifier_names
// import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:nazar_e_alam/data/model/response/language_model.dart';
import 'package:nazar_e_alam/util/images.dart';

class AppConstants {
  // Flutter SDK Version  3.44.0
  static const String APP_NAME = 'Nazar e Aalam';
  static const String APP_VERSION = "7.0";

  // main base url
  // static const String BASE_URL = "https://zer0spectrum.dpdns.org";
  static const String BASE_URL = "https://zabi.theme29.com";

  // API's and API Kay's
  static const String HADITH_BASE_URL = 'https://www.hadithapi.com/public';
  static const String NEARBY_MOSQUE_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch';

  //Endpoint url
  static const String SURA_LIST = "/api/chapters";
  static const String SURA_Detaile = "/api/verses/";
  static const String JUZ_LIST = "/api/juzes";
  static const String TRANSLATOR_ID = "?translator_id=";
  static const String DUA_LIST = "/api/dua-list";
  static const String DUA_DETAILES = "/api/dua-details/";
  static const String DIKIR_LIST = "/api/dhikr-list";
  static const String DIKIR_DETAILES = "/api/dhikr-details/";
  static const String SIFAT_NAME_LIST = "/api/sifat-name-list";
  static const String SIFAT_NAME_DETAILES = "/api/sifat-name-details/";
  static const String HARAM_FOOD_LIST = "/api/haram-code-list";
  static const String TODAYS_PRAYER_TIME = "/api/today-prayer-time";
  static const String MOSQUE_SETTINGS = "/api/settings";
  static const String TRANSLATOR = "/api/translators";
  // static const String DONATION_Category = "/api/donation-categories";
  // static const String DONATED_LIST = "/api/donation-list";
  // static const String DONATION_STORE = "/api/donation-store";
  // static const String PAYMENT_METHODS = "/api/payment-methods";
  static const String CITY_LIST = "/api/get-cities";
  static const String RECITERS = "/api/reciters";
  static const String AUDIO_LIST = "/api/reciter-sura/";
  static const String WALLPAPER_LIST = "/api/wallpapers";
  static const String IS_MANUAL_PRAYER_TIME = 'is_manual_prayer_time';
  //others key

  // Shared Key
  static const String THEME = 'theme';
  static const String isPrayerTme = 'isPrayerTme';
  static const String saveCityName = 'saveCityName';
  static const String notificationSettingsKey = 'prayer_notification_settings';
  static const String HOME_LAYOUT_OVERRIDE_KEY = 'home_layout_override';
  static const String QURAN_MILESTONE_GOAL_KEY = 'quran_milestone_daily_goal';
  static const String QURAN_MILESTONE_PROGRESS_KEY = 'quran_milestone_progress';
  static const String TodaysPrayerTimeModel = 'today_time_prayer';

  // Language Key
  static const String LANGUAGE_CODE = 'language_code';
  static const String COUNTRY_CODE = 'country_code';

  // Islamic Name
  // static const String FAVORITE_KEY = 'islamic_name_favorites';

  // All Language model list section
  static List<LanguageModel> languages = [
    LanguageModel(
      imageUrl: Images.englishIcon,
      languageName: 'English',
      countryCode: 'US',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: Images.indiaIcon,
      languageName: 'Hindi',
      countryCode: 'IN',
      languageCode: 'hi',
    ),
    LanguageModel(
      imageUrl: Images.indiaIcon,
      languageName: 'Gujarati',
      countryCode: 'IN',
      languageCode: 'guj',
    ),
    LanguageModel(
      imageUrl: Images.arabicIcon,
      languageName: 'Arabic',
      countryCode: 'SA',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: Images.kenyaIcon,
      languageName: 'Swahili',
      countryCode: 'KE',
      languageCode: 'sw',
    ),
    LanguageModel(
      imageUrl: Images.pakistanIcon,
      languageName: 'Urdu',
      countryCode: 'PK',
      languageCode: 'ur',
    ),
  ];
}
