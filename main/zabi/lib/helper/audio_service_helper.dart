import 'package:audio_service/audio_service.dart';
import 'package:nazar_e_alam/helper/audio_handler.dart';

class AudioServiceHelper {
  static AudioHandler? _audioHandler;

  /// Initializes the audio handler if not already initialized
  static Future<void> init() async {
    if (_audioHandler != null) return;

    _audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.muslimPath.muslimPath',
        androidNotificationChannelName: 'Audio Playback',
        androidNotificationIcon: 'mipmap/launcher_icon',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationClickStartsActivity: true,
      ),
    );
  }

  /// Accessor for the audio handler
  static AudioHandler get audioHandler {
    if (_audioHandler == null) {
      throw Exception('AudioHandler not initialized. Call init() first.');
    }
    return _audioHandler!;
  }
}
