import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/streak_data.dart';
import '../models/user_progress.dart';

class ProgressRepository {
  static const _prefix = 'progress_';
  static const _streakKey = 'streak_data';

  Future<QuestionProgress> getProgress(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$questionId');
    if (raw == null) {
      return QuestionProgress(questionId: questionId);
    }
    return QuestionProgress.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProgress(QuestionProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix${progress.questionId}',
      json.encode(progress.toJson()),
    );
  }

  Future<Map<String, QuestionProgress>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, QuestionProgress>{};

    for (final key in prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        final questionId = key.substring(_prefix.length);
        final raw = prefs.getString(key);
        if (raw != null) {
          result[questionId] = QuestionProgress.fromJson(
            json.decode(raw) as Map<String, dynamic>,
          );
        }
      }
    }
    return result;
  }

  Future<StreakData> getStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_streakKey);
    if (raw == null) return StreakData();
    return StreakData.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<void> recordActivityToday() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = await getStreakData();
    final today = _dateKey(DateTime.now());
    final yesterday =
        _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    int newStreak = streak.currentStreak;
    if (streak.lastActiveDate == today) {
      return;
    } else if (streak.lastActiveDate == yesterday) {
      newStreak++;
    } else {
      newStreak = 1;
    }

    final updated = streak.copyWith(
      currentStreak: newStreak,
      longestStreak:
          newStreak > streak.longestStreak ? newStreak : streak.longestStreak,
      lastActiveDate: today,
      activeDays: {...streak.activeDays, today},
    );

    await prefs.setString(_streakKey, json.encode(updated.toJson()));
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

