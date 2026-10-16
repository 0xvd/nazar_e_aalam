import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/data/model/response/reciters_model.dart';
import 'package:nazar_e_alam/helper/audio_handler.dart';
import 'package:nazar_e_alam/helper/audio_service_helper.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class AudioPlayerController extends GetxController {
  final ApiClient apiClient;

  AudioPlayerController({required this.apiClient});

  // Reciter API call
  RxBool isRecitersLoading = false.obs;
  RecitersModel? recitersListApiData;

  // Get dua list from here
  Future<void> fetchReciterData() async {
    try {
      isRecitersLoading(true);
      final response = await apiClient.getData(AppConstants.RECITERS);

      if (response.statusCode == 200) {
        recitersListApiData = RecitersModel.fromJson(response.body);
        if (kDebugMode) {
          print("Reciters List: ${recitersListApiData!.data!.length}");
        }
      } else {
        if (kDebugMode) {
          print("Error fetching data 2222: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data 111: $e");
      }
    } finally {
      isRecitersLoading(false);
      update();
    }
  }

  // Reciter audio list
  RxBool isAudioLoading = false.obs;
  List<dynamic> audioData = [];

  Future<void> fetchAudio(String id) async {
    try {
      audioData.clear();
      isAudioLoading(true);
      final response = await apiClient.getData(AppConstants.AUDIO_LIST + id);

      if (response.statusCode == 200) {
        audioData = response.body["data"];
        if (kDebugMode) {
          print("Audio List: ${audioData[0]["reciter_name"]}");
        }
      } else {
        if (kDebugMode) {
          print("Error fetching data qfqwf: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data 4444: $e");
      }
    } finally {
      isAudioLoading(false);
      update();
    }
  }

  // Audio player controller starts
  final AudioHandler _audioHandler = AudioServiceHelper.audioHandler;
  final RxList<MediaItem> audioList = <MediaItem>[].obs;
  final Rx<MediaItem?> currentMediaItem = Rx<MediaItem?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  // Future<void> ensureAudioHandlerRunning() async {
  //   if (!_audioHandler.playbackState.value.playing &&
  //       _audioHandler.queue.value.isEmpty) {
  //     // Reinitialize the AudioHandler
  //     AudioService.init(
  //       builder: () => AudioPlayerHandler(),
  //       config: const AudioServiceConfig(
  //         androidNotificationChannelId: 'com.muslimPath.muslimPath ',
  //         androidNotificationChannelName: 'Audio playback',
  //         androidNotificationIcon: 'mipmap/launcher_icon',
  //         androidNotificationOngoing: true,
  //       ),
  //     );
  //   }
  // }

  Future<void> loadAudioList(String id) async {
    await fetchAudio(id);

    // Cast the AudioHandler to AudioPlayerHandler to access loadAudioFromApi
    if (_audioHandler is AudioPlayerHandler) {
      await (_audioHandler).loadAudioFromApi(audioData);
    } else {
      throw Exception('AudioHandler is not an instance of AudioPlayerHandler');
    }

    try {
      isLoading(true);
      update();
      audioList.clear();

      // Loop through the fetched API audio data
      for (var audio in audioData) {
        // Handle duration safely
        final int? audioDuration = audio['duration'] != null
            ? audio['duration'] is int
                ? audio['duration']
                : int.tryParse(audio['duration'].toString())
            : 0;

        final mediaItem = MediaItem(
          id: audio['path'],
          album: audio['sura_name'] ?? 'Unknown Album',
          title: audio['sura_name'] ?? 'Unknown Title',
          artist: audio['reciter_name'] ?? 'Unknown Artist',
          duration: Duration(
              milliseconds: audioDuration ?? 0), // Ensure this is a Duration
          artUri: Uri.tryParse(audio['reciter_avatar'] ?? ''),
        );
        audioList.add(mediaItem);
      }

      // Inside the loadAudioList method, after setting currentMediaItem
      if (audioList.isNotEmpty) {
        currentMediaItem.value = audioList[0];
        await _audioHandler.updateQueue(audioList.toList());

        // Listen to media item changes
        _audioHandler.mediaItem.listen((item) {
          currentMediaItem.value = item;
          duration.value = item?.duration ?? Duration.zero;
          // Refresh the UI
          update();
        });

        // Listen to playback state changes
        _audioHandler.playbackState.listen((state) async {
          isPlaying.value = state.playing;

          // Update position and handle buffering or paused states
          position.value = state.updatePosition;
          update();

          if (state.processingState == AudioProcessingState.ready) {
            duration.value = currentMediaItem.value?.duration ?? Duration.zero;
          }

          // Automatically play the first audio if the last one is finished
          if (state.processingState == AudioProcessingState.completed) {
            if (currentMediaItem.value == audioList.last) {
              await _audioHandler.pause();
              Get.back();
            } else {
              // Skip to next if not the last audio
              await _audioHandler.skipToNext();
            }
          }
          // if (state.processingState == AudioProcessingState.completed ||
          //     state.processingState == AudioProcessingState.ready) {
          //   AudioServiceHelper.init();
          // }

          update();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading audio list: $e');
      }
    } finally {
      isLoading(false);
      update();
    }
  }

  Future<void> playMediaItem(MediaItem mediaItem) async {
    // if (_audioHandler.playbackState.value.processingState ==
    //     AudioProcessingState.idle) {
    //   await ensureAudioHandlerRunning();
    // }
    await _audioHandler.playMediaItem(mediaItem);
    update();
  }

  void togglePlayPause() async {
    if (isPlaying.value) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  Future<void> skipToNext() async => await _audioHandler.skipToNext();

  Future<void> skipToPrevious() async => await _audioHandler.skipToPrevious();

  Future<void> seekToPosition(double value) async {
    if (value >= 0 && value <= duration.value.inMilliseconds) {
      await _audioHandler.seek(Duration(milliseconds: value.toInt()));
    }
  }
}
