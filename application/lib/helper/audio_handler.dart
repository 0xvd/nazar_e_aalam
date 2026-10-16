// ignore_for_file: deprecated_member_use

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final List<MediaItem> _mediaItems = [];
  final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);

  AudioPlayerHandler() {
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // Load audio fetched from API into the audio player
  Future<void> loadAudioFromApi(List<dynamic> audioData) async {
    _mediaItems.clear();
    _playlist.clear();

    for (var audio in audioData) {
      final audioSource = AudioSource.uri(Uri.parse(audio['path']));
      _playlist.add(audioSource);

      final mediaItem = MediaItem(
        id: audio['path'],
        album: audio['sura_name'] ?? 'Unknown Album',
        title: audio['sura_name'] ?? 'Unknown Title',
        artist: audio['reciter_name'] ?? 'Unknown Artist',
        duration: Duration(milliseconds: audio['duration'] ?? 0),
        artUri: Uri.tryParse(audio['reciter_avatar'] ?? ''),
      );
      _mediaItems.add(mediaItem);
    }
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting audio source: $e');
      }
    }
    queue.add(_mediaItems);

    if (_mediaItems.isNotEmpty) {
      mediaItem.add(_mediaItems[0]);
    }

    // Stream current index and update the mediaItem when needed
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _mediaItems.length) {
        mediaItem.add(_mediaItems[index]);
      }
    });
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    final index = _mediaItems.indexOf(mediaItem);
    if (index != -1) {
      await _player.seek(Duration.zero, index: index);
      await play();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.dispose();
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3], // Compact action buttons
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
