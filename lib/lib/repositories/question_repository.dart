import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionRepository {
  List<SqlQuestion>? _cache;

  Future<List<SqlQuestion>> getAllQuestions() async {
    if (_cache != null) return _cache!;

    // Load the questions manifest first
    final manifestJson = await rootBundle.loadString(
      'assets/questions/manifest.json',
    );
    final manifest = json.decode(manifestJson) as List;

    final questions = <SqlQuestion>[];
    for (final fileName in manifest) {
      final raw = await rootBundle.loadString(
        'assets/questions/$fileName',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      questions.add(SqlQuestion.fromJson(data));
    }

    _cache = questions;
    return questions;
  }

  Future<SqlQuestion?> getQuestionById(String id) async {
    final all = await getAllQuestions();
    try {
      return all.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<SqlQuestion>> getByCategory(String category) async {
    final all = await getAllQuestions();
    return all.where((q) => q.category == category).toList();
  }

  Future<List<SqlQuestion>> getByDifficulty(Difficulty difficulty) async {
    final all = await getAllQuestions();
    return all.where((q) => q.difficulty == difficulty).toList();
  }

  Future<List<String>> getCategories() async {
    final all = await getAllQuestions();
    return all.map((q) => q.category).toSet().toList()..sort();
  }
}
