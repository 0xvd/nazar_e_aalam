import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

/// Lightweight local-only "daily Quran reading goal" tracker.
/// Counts each distinct surah opened (online or offline reader) once per
/// calendar day, purely for the Modern home screen's milestone card.
class QuranMilestoneController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  QuranMilestoneController({required this.sharedPreferences}) {
    _load();
  }

  static const int defaultDailyGoal = 20;

  final RxInt dailyGoal = defaultDailyGoal.obs;
  final RxInt pagesReadToday = 0.obs;
  Set<int> _readSurahIdsToday = {};

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _load() {
    dailyGoal.value =
        sharedPreferences.getInt(AppConstants.QURAN_MILESTONE_GOAL_KEY) ??
        defaultDailyGoal;

    final savedDate = sharedPreferences.getString(
      '${AppConstants.QURAN_MILESTONE_PROGRESS_KEY}_date',
    );
    if (savedDate == _todayKey) {
      final savedIds = sharedPreferences.getStringList(
        AppConstants.QURAN_MILESTONE_PROGRESS_KEY,
      );
      _readSurahIdsToday = (savedIds ?? []).map(int.parse).toSet();
      pagesReadToday.value = _readSurahIdsToday.length;
    } else {
      _readSurahIdsToday = {};
      pagesReadToday.value = 0;
    }
  }

  Future<void> markSurahRead(int? surahId) async {
    if (surahId == null) return;

    // Roll over to a new day if needed.
    final savedDate = sharedPreferences.getString(
      '${AppConstants.QURAN_MILESTONE_PROGRESS_KEY}_date',
    );
    if (savedDate != _todayKey) {
      _readSurahIdsToday = {};
      pagesReadToday.value = 0;
    }

    if (_readSurahIdsToday.contains(surahId)) return;

    _readSurahIdsToday.add(surahId);
    pagesReadToday.value = _readSurahIdsToday.length;

    await sharedPreferences.setString(
      '${AppConstants.QURAN_MILESTONE_PROGRESS_KEY}_date',
      _todayKey,
    );
    await sharedPreferences.setStringList(
      AppConstants.QURAN_MILESTONE_PROGRESS_KEY,
      _readSurahIdsToday.map((e) => e.toString()).toList(),
    );
  }

  double get progressRatio =>
      dailyGoal.value <= 0
      ? 0
      : (pagesReadToday.value / dailyGoal.value).clamp(0, 1);
}
