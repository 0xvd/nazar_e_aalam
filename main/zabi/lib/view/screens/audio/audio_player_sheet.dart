// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import 'package:nazar_e_alam/controller/audio_player_controller.dart';

class FullScreenBottomSheet extends StatelessWidget {
  final AudioPlayerController controller;

  const FullScreenBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).cardColor,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildDragHandle(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Obx(() {
                final mediaItem = controller.currentMediaItem.value;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMediaImage(mediaItem?.artUri),
                    _buildMediaInfo(mediaItem),
                    _buildSlider(mediaItem),
                    _buildControlButtons(),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildMediaImage(Uri? artUri) {
    return Hero(
      tag: 'album-art'.tr,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            )
          ],
          borderRadius: BorderRadius.circular(500),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(500),
          child: artUri != null
              ? Image.network(
                  artUri.toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderArt(),
                )
              : _buildPlaceholderArt(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderArt() {
    return Container(
      color: Get.theme.colorScheme.primary.withOpacity(0.2),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: 80,
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildMediaInfo(MediaItem? mediaItem) {
    return Column(
      children: [
        Text(
          mediaItem?.title ?? 'unknown_title_key'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          mediaItem?.artist ?? 'unknown_artist_key'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSlider(MediaItem? mediaItem) {
    return StreamBuilder<Duration>(
      stream: AudioService.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = mediaItem?.duration ?? Duration.zero;

        return Column(
          children: [
            Slider(
              min: 0,
              max: duration.inMilliseconds.toDouble(),
              value: position.inMilliseconds
                  .toDouble()
                  .clamp(0, duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                controller.seekToPosition(value);
              },
              activeColor: Get.theme.colorScheme.primary,
              inactiveColor: Get.theme.colorScheme.primary.withOpacity(0.2),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(Icons.skip_previous, controller.skipToPrevious),
        _buildPlayPauseButton(),
        _buildIconButton(Icons.skip_next, controller.skipToNext),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 40,
          color: Get.isDarkMode ? Colors.grey.shade400 : Colors.black,
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 32,
          backgroundColor: Get.theme.colorScheme.primary,
          child: IconButton(
            iconSize: 36,
            onPressed: controller.togglePlayPause,
            icon: controller.isPlaying.value
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
            color: Colors.white,
          ),
        ),
      );
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }
}
