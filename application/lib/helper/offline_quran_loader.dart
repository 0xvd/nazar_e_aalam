// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:nazar_e_alam/helper/arabic_utils.dart';

class QuranLoader {
  // Singleton (optional)
  QuranLoader._();
  static final QuranLoader instance = QuranLoader._();

  List<Map<String, dynamic>> _cachedVerses = [];

  /// Call once at app startup to load & cache all verses
  Future<void> loadAllVerses({int totalSurah = 114}) async {
    if (_cachedVerses.isNotEmpty) return; // already loaded

    final verses = <Map<String, dynamic>>[];

    for (int i = 1; i <= totalSurah; i++) {
      try {
        final path = 'assets/quran/en/s00$i.json';
        final raw = await rootBundle.loadString(path);
        final decoded = json.decode(raw);

        // Some files might be an array or single map; normalize
        final surahData = (decoded is List)
            ? decoded.first as Map<String, dynamic>
            : decoded as Map<String, dynamic>;
        final data = surahData['data'] as Map<String, dynamic>?;

        if (data == null) continue;
        final chapter = data['chapter'] as Map<String, dynamic>? ?? {};
        final chapterInfoList = (data['chapter_info'] as List?) ?? [];

        for (final info in chapterInfoList) {
          final pageNumber = info['page_number'];
          final pageKey = info['page_key'];
          final pageVerses = (info['page_verses'] as List?) ?? [];

          for (final v in pageVerses) {
            // Build verse map in the exact shape you described.
            final verseMap = <String, dynamic>{
              "id": v["id"],
              "chapter_id": v["chapter_id"],
              "arabic_name": v["arabic_name"],
              // if you have a "text_without_taskeel" field in your JSON use it; otherwise derive it
              "text_without_taskeel":
                  v["text_without_taskeel"] ??
                  removeDiacritics(v["arabic_name"] ?? ''),
              "verse_number": v["verses_number"] ?? v["verse_number"],
              "verse_key":
                  "${chapter['id'] ?? v['chapter_id']}:${v['verses_number'] ?? v['verse_number']}",
              // If you have these fields in source JSON use them; here we set sensible defaults
              "hizb_number": v['hizb_number'] ?? 0,
              "rub_el_hizb_number": v['rub_el_hizb_number'] ?? 0,
              "ruku_number": v['ruku_number'] ?? 0,
              "manzil_number": v['manzil_number'] ?? 0,
              "sajdah_number": v['sajdah_number'] ?? 0,
              "page_number": pageNumber,
              "page_key": pageKey,
              "juz_number": v['juz_number'] ?? 0,
              "created_at": v['created_at'] ?? "2023-12-01T17:30:04.000000Z",
              "updated_at": v['updated_at'] ?? "2025-10-14T11:28:07.000000Z",
              "chapter": {
                "id": chapter['id'],
                "arabic_name": chapter['arabic_name'],
                "verses_count": chapter['verses_count'],
                "revelation_place":
                    chapter['revelation_place'] ?? chapter['revelation_place'],
                "revelation_order":
                    chapter['revelation_order'] ?? chapter['revelation_order'],
              },
            };

            verses.add(verseMap);
          }
        }
      } catch (e) {
        // If a file misses or parsing fails, we print but continue
        // In production you might want to log this.
        print("Error loading surah $i: $e");
      }
    }

    _cachedVerses = verses;
    print("Loaded ${_cachedVerses.length} verses into cache.");
  }

  /// Returns full cached list (call loadAllVerses first)
  List<Map<String, dynamic>> get allVerses => _cachedVerses;
}
