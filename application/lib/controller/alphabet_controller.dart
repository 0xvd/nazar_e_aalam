// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:get/get.dart';
//
// class AlphabetController extends GetxController implements GetxService {
//   final FlutterTts _flutterTts = FlutterTts();
//
//   // Common 28-letter Arabic alphabet
//
//   final List<String> letters = const [
//     'ا',
//     'ب',
//     'ت',
//     'ث',
//     'ج',
//     'ح',
//     'خ',
//     'د',
//     'ذ',
//     'ر',
//     'ز',
//     'س',
//     'ش',
//     'ص',
//     'ض',
//     'ط',
//     'ظ',
//     'ع',
//     'غ',
//     'ف',
//     'ق',
//     'ك',
//     'ل',
//     'م',
//     'ن',
//     'ه',
//     'و',
//     'ي',
//   ];
//
//   // Available voices (male / female, etc.)
//   var availableVoices = <Map>[].obs;
//   var selectedVoice = Rxn<Map>();
//
//
//   @override
//   void onInit() async{
//     super.onInit();
//     _flutterTts.setLanguage("ar");
//     _flutterTts.setPitch(0.8);
//     _flutterTts.setSpeechRate(0.4);
//     // await _flutterTts.setVoice({"identifier": "com.apple.voice.compact.en-AU.Karen"});
//   }
//   Future<void> _initTts() async {
//     await _flutterTts.setLanguage("ar");
//     await _flutterTts.setPitch(1.0);
//     await _flutterTts.setSpeechRate(0.4);
//
//     // Load voices from engine
//     final voices = await _flutterTts.getVoices;
//     if (voices is List) {
//       // Filter Arabic voices only
//       availableVoices.value = voices
//           .where((v) =>
//       v is Map &&
//           (v['locale']?.toString().startsWith('ar') ?? false))
//           .cast<Map>()
//           .toList();
//
//       // Default: pick first female if exists, otherwise first
//       final defaultVoice = availableVoices.firstWhere(
//             (v) => v['name'].toString().toLowerCase().contains('female'),
//         orElse: () => availableVoices.isNotEmpty ? availableVoices.first : {},
//       );
//
//       if (defaultVoice.isNotEmpty) {
//         setVoice(defaultVoice);
//       }
//     }
//   }
//
//   Future<void> setVoice(Map voice) async {
//     selectedVoice.value = voice;
//     await _flutterTts.setVoice({
//       'name': voice['name'],
//       'locale': voice['locale'],
//     });
//   }
//
//   Future<void> speak(String text) async {
//     try {
//       await _flutterTts.stop();
//     } catch (_) {}
//     await _flutterTts.speak(text);
//   }
// }

//
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:get/get.dart';
//
// class AlphabetController extends GetxController implements GetxService {
//   final FlutterTts _flutterTts = FlutterTts();
//
//   final List<String> letters = const [
//     'ا','ب','ت','ث','ج','ح','خ','د','ذ','ر','ز','س','ش','ص','ض',
//     'ط','ظ','ع','غ','ف','ق','ك','ل','م','ن','ه','و','ي',
//   ];
//
//   var availableVoices = <Map>[].obs;
//   var selectedVoice = Rxn<Map>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initTts();
//   }
//
//   Future<void> _initTts() async {
//     await _flutterTts.setLanguage("ar");
//     await _flutterTts.setPitch(1.0);
//     await _flutterTts.setSpeechRate(0.4);
//
//     // Fetch available voices
//     final voices = await _flutterTts.getVoices;
//     if (voices is List) {
//       availableVoices.value = voices
//           .where((v) => v is Map && (v['locale']?.toString().startsWith('ar') ?? false))
//           .cast<Map>()
//           .toList();
//
//       if (availableVoices.isNotEmpty) {
//         // default: first voice
//         setVoice(availableVoices.first);
//       }
//     }
//   }
//
//   Future<void> setVoice(Map voice) async {
//     selectedVoice.value = voice;
//     await _flutterTts.setVoice({'name': voice['name'], 'locale': voice['locale']});
//   }
//
//   Future<void> speak(String text) async {
//     await _flutterTts.stop();
//     await _flutterTts.speak(text);
//   }
// }
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlphabetController extends GetxController implements GetxService {
  final FlutterTts _flutterTts = FlutterTts();

  final List<String> letters = const [
    'ا','ب','ت','ث','ج','ح','خ','د','ذ','ر','ز','س','ش','ص','ض',
    'ط','ظ','ع','غ','ف','ق','ك','ل','م','ن','ه','و','ي',
  ];

  var availableVoices = <Map>[].obs;
  var selectedVoice = Rxn<Map>();
  var pitch = 1.0.obs;
  var rate = 0.4.obs;
  var voiceDisplayNames = <Map, String>{};

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  /// Initialize TTS and load saved settings
  Future<void> _initTts() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved values
    pitch.value = prefs.getDouble('tts_pitch') ?? 1.0;
    rate.value = prefs.getDouble('tts_rate') ?? 0.4;
    final savedVoiceName = prefs.getString('tts_voice');

    await _flutterTts.setLanguage("ar");
    await _flutterTts.setPitch(pitch.value);
    await _flutterTts.setSpeechRate(rate.value);

    final voices = await _flutterTts.getVoices;
    if (voices is List) {
      availableVoices.value = voices
          .where((v) => v is Map && (v['locale']?.toString().startsWith('ar') ?? false))
          .cast<Map>()
          .toList();

      int count = 1;
      for (var v in availableVoices) {
        voiceDisplayNames[v] = 'Voice $count';
        count++;
      }

      // Restore saved voice if available
      if (savedVoiceName != null) {
        final match = availableVoices.firstWhereOrNull((v) => v['name'] == savedVoiceName);
        if (match != null) {
          await setVoice(match, save: false);
        }
      } else if (availableVoices.isNotEmpty) {
        await setVoice(availableVoices.first, save: false);
      }
    }
  }

  Future<void> setVoice(Map voice, {bool save = true}) async {
    selectedVoice.value = voice;
    await _flutterTts.setVoice({'name': voice['name'], 'locale': voice['locale']});

    if (save) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tts_voice', voice['name']);
    }
  }

  Future<void> setPitch(double value) async {
    pitch.value = value;
    await _flutterTts.setPitch(value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_pitch', value);
  }

  Future<void> setRate(double value) async {
    rate.value = value;
    await _flutterTts.setSpeechRate(value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_rate', value);
  }

  Future<void> speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  /// Reset to defaults
  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tts_pitch');
    await prefs.remove('tts_rate');
    await prefs.remove('tts_voice');

    pitch.value = 1.0;
    rate.value = 0.4;
    if (availableVoices.isNotEmpty) {
      await setVoice(availableVoices.first);
    }

    await _flutterTts.setPitch(pitch.value);
    await _flutterTts.setSpeechRate(rate.value);
  }
}
