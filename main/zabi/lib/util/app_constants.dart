// ignore_for_file: constant_identifier_name, constant_identifier_names
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
  static const String NEARBY_MOSQUE_URL =
      'https://maps.googleapis.com/maps/api/place/nearbysearch';

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
  static const String DONATION_Category = "/api/donation-categories";
  static const String DONATED_LIST = "/api/donation-list";
  static const String DONATION_STORE = "/api/donation-store";
  static const String PAYMENT_METHODS = "/api/payment-methods";
  static const String CITY_LIST = "/api/get-cities";
  static const String RECITERS = "/api/reciters";
  static const String AUDIO_LIST = "/api/reciter-sura/";
  static const String WALLPAPER_LIST = "/api/wallpapers";

  //others key
  static const String HADITH_API_KEY =
      "\$2y\$10\$IpN2jMeSLbrGxZ6zwEu3KAEr1ZmUjwQCYhRbiReqscXswndm";
  static const String MAPS_API_KEY = 'AIzaSyCQc4sar_LVjT8M_vC_ubqCoGwGlR-TU3Q';

  // Shared Key
  static const String THEME = 'theme';
  static const String isPrayerTme = 'isPrayerTme';
  static const String saveCityName = 'saveCityName';
  static const String notificationSettingsKey = 'prayer_notification_settings';
  static const String IS_MANUAL_PRAYER_TIME = 'is_manual_prayer_time';
  static const String HOME_LAYOUT_OVERRIDE_KEY = 'home_layout_override';
  static const String QURAN_MILESTONE_GOAL_KEY = 'quran_milestone_daily_goal';
  static const String QURAN_MILESTONE_PROGRESS_KEY =
      'quran_milestone_progress';

  // Language Key
  static const String LANGUAGE_CODE = 'language_code';
  static const String COUNTRY_CODE = 'country_code';

  // Islamic Name
  static const String GROK_END_POINT =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String FAVORITE_KEY = 'islamic_name_favorites';

  // All Language model list section
  static List<LanguageModel> languages = [
    LanguageModel(
      imageUrl: Images.englishIcon,
      languageName: 'English',
      countryCode: 'US',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: Images.afghanistanIcon,
      languageName: 'Afghanistan',
      countryCode: 'AF',
      languageCode: 'fa',
    ),
    LanguageModel(
      imageUrl: Images.algeriaIcon,
      languageName: 'Algeria',
      countryCode: 'DZ',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: Images.argentinaIcon,
      languageName: 'Argentina',
      countryCode: 'AR',
      languageCode: 'es',
    ),
    LanguageModel(
      imageUrl: Images.arabicIcon,
      languageName: 'Arabic',
      countryCode: 'SA',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: Images.bangladeshIcon,
      languageName: 'Bangladesh',
      countryCode: 'BD',
      languageCode: 'bn',
    ),
    LanguageModel(
      imageUrl: Images.brazilIcon,
      languageName: 'Brazil',
      countryCode: 'BR',
      languageCode: 'pt',
    ),
    LanguageModel(
      imageUrl: Images.chinaIcon,
      languageName: 'Chinese',
      countryCode: 'CN',
      languageCode: 'zh',
    ),
    LanguageModel(
      imageUrl: Images.croatiaIcon,
      languageName: 'Croatia',
      countryCode: 'HR',
      languageCode: 'hr',
    ),
    LanguageModel(
      imageUrl: Images.cyprusIcon,
      languageName: 'Cyprus',
      countryCode: 'CY',
      languageCode: 'el',
    ),
    LanguageModel(
      imageUrl: Images.denmarkIcon,
      languageName: 'Denmark',
      countryCode: 'DK',
      languageCode: 'da',
    ),
    LanguageModel(
      imageUrl: Images.finlandIcon,
      languageName: 'Finland',
      countryCode: 'FI',
      languageCode: 'fi',
    ),
    LanguageModel(
      imageUrl: Images.franceIcon,
      languageName: 'France',
      countryCode: 'FR',
      languageCode: 'fr',
    ),
    LanguageModel(
      imageUrl: Images.germanyIcon,
      languageName: 'Germany',
      countryCode: 'DE',
      languageCode: 'de',
    ),
    LanguageModel(
      imageUrl: Images.greeceIcon,
      languageName: 'Greece',
      countryCode: 'GR',
      languageCode: 'el',
    ),
    LanguageModel(
      imageUrl: Images.indiaIcon,
      languageName: 'India',
      countryCode: 'IN',
      languageCode: 'hi',
    ),
    LanguageModel(
      imageUrl: Images.indonesiaIcon,
      languageName: 'Indonesia',
      countryCode: 'ID',
      languageCode: 'id',
    ),
    LanguageModel(
      imageUrl: Images.irelandIcon,
      languageName: 'Ireland',
      countryCode: 'IE',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: Images.italyIcon,
      languageName: 'Italy',
      countryCode: 'IT',
      languageCode: 'it',
    ),
    LanguageModel(
      imageUrl: Images.japanIcon,
      languageName: 'Japan',
      countryCode: 'JP',
      languageCode: 'ja',
    ),
    LanguageModel(
      imageUrl: Images.kenyaIcon,
      languageName: 'Kenya',
      countryCode: 'KE',
      languageCode: 'sw',
    ),
    LanguageModel(
      imageUrl: Images.malaysiaIcon,
      languageName: 'Malaysia',
      countryCode: 'MY',
      languageCode: 'ms',
    ),
    LanguageModel(
      imageUrl: Images.mexicoIcon,
      languageName: 'Mexico',
      countryCode: 'MX',
      languageCode: 'es',
    ),
    LanguageModel(
      imageUrl: Images.moroccoIcon,
      languageName: 'Morocco',
      countryCode: 'MA',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: Images.netherlandsIcon,
      languageName: 'Netherlands',
      countryCode: 'NL',
      languageCode: 'nl',
    ),
    LanguageModel(
      imageUrl: Images.nigeriaIcon,
      languageName: 'Nigeria',
      countryCode: 'NG',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: Images.norwayIcon,
      languageName: 'Norway',
      countryCode: 'NO',
      languageCode: 'no',
    ),
    LanguageModel(
      imageUrl: Images.pakistanIcon,
      languageName: 'Pakistan',
      countryCode: 'PK',
      languageCode: 'ur',
    ),
    LanguageModel(
      imageUrl: Images.palestineIcon,
      languageName: 'Palestine',
      countryCode: 'PS',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: Images.philippinesIcon,
      languageName: 'Philippines',
      countryCode: 'PH',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: Images.polandIcon,
      languageName: 'Poland',
      countryCode: 'PL',
      languageCode: 'pl',
    ),
    LanguageModel(
      imageUrl: Images.portugalIcon,
      languageName: 'Portugal',
      countryCode: 'PT',
      languageCode: 'pt',
    ),
    LanguageModel(
      imageUrl: Images.romaniaIcon,
      languageName: 'Romania',
      countryCode: 'RO',
      languageCode: 'ro',
    ),
    LanguageModel(
      imageUrl: Images.russiaIcon,
      languageName: 'Russia',
      countryCode: 'RU',
      languageCode: 'ru',
    ),
    LanguageModel(
      imageUrl: Images.singaporeIcon,
      languageName: 'Singapore',
      countryCode: 'SG',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: Images.southAfricaIcon,
      languageName: 'South Africa',
      countryCode: 'ZA',
      languageCode: 'af',
    ),
    LanguageModel(
      imageUrl: Images.spainIcon,
      languageName: 'Spain',
      countryCode: 'ES',
      languageCode: 'es',
    ),
    LanguageModel(
      imageUrl: Images.sriLankaIcon,
      languageName: 'Sri Lanka',
      countryCode: 'LK',
      languageCode: 'si',
    ),
    LanguageModel(
      imageUrl: Images.swedenIcon,
      languageName: 'Sweden',
      countryCode: 'SE',
      languageCode: 'sv',
    ),
    LanguageModel(
      imageUrl: Images.switzerlandIcon,
      languageName: 'Switzerland',
      countryCode: 'CH',
      languageCode: 'de',
    ),
    LanguageModel(
      imageUrl: Images.thailandIcon,
      languageName: 'Thailand',
      countryCode: 'TH',
      languageCode: 'th',
    ),
    LanguageModel(
      imageUrl: Images.turukishIcon,
      languageName: 'Turkish',
      countryCode: 'TR',
      languageCode: 'tr',
    ),
    LanguageModel(
      imageUrl: Images.uzbekistanIcon,
      languageName: 'Uzbekistan',
      countryCode: 'UZ',
      languageCode: 'uz',
    ),
  ];
}
