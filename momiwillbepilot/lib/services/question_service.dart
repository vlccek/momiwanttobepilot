import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:momiwillbepilot/models/question.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionService {
  static const _questionStatisticsKey = 'questionStatistics';

  static Future<List<Question>> loadQuestions() async {
    final String response = await rootBundle.loadString('assets/unikatni_otazky_obohatene.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Question.fromJson(json)).toList();
  }

  static Future<Map<String, Map<String, int>>> getQuestionStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_questionStatisticsKey);
    if (statsJson == null) {
      return {};
    }
    final Map<String, dynamic> decoded = json.decode(statsJson);
    return decoded.map((key, value) => MapEntry(key, Map<String, int>.from(value)));
  }

  static Future<void> _saveQuestionStatistics(Map<String, Map<String, int>> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(stats);
    await prefs.setString(_questionStatisticsKey, encoded);
  }

  static Future<void> recordAnswer(String questionId, bool isCorrect) async {
    final stats = await getQuestionStatistics();
    stats.putIfAbsent(questionId, () => {'correctCount': 0, 'incorrectCount': 0});

    final questionStats = stats[questionId];

    if (questionStats != null) {
      if (isCorrect) {
        questionStats['correctCount'] = (questionStats['correctCount'] ?? 0) + 1;
      } else {
        questionStats['incorrectCount'] = (questionStats['incorrectCount'] ?? 0) + 1;
      }
    }
    await _saveQuestionStatistics(stats);
  }

  static Future<void> clearStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_questionStatisticsKey);
  }

  // The following methods are now deprecated or need to be re-evaluated based on new statistics storage
  static Future<List<String>> getAnsweredQuestionIds() async {
    final stats = await getQuestionStatistics();
    return stats.keys.toList();
  }

  static Future<List<String>> getIncorrectlyAnsweredQuestionIds() async {
    final stats = await getQuestionStatistics();
    return stats.entries
        .where((entry) => (entry.value['incorrectCount'] ?? 0) > 0)
        .map((entry) => entry.key)
        .toList();
  }

  static Future<void> addAnsweredQuestionId(String id) async {
    // This method is now handled by recordAnswer
  }

  static Future<void> addIncorrectlyAnsweredQuestionId(String id) async {
    // This method is now handled by recordAnswer
  }

  static Future<void> removeIncorrectlyAnsweredQuestionId(String id) async {
    final stats = await getQuestionStatistics();
    if (stats.containsKey(id)) {
      stats[id]!['incorrectCount'] = 0; // Reset incorrect count
      await _saveQuestionStatistics(stats);
    }
  }

  static Future<List<Question>> getUnansweredQuestions() async {
    final allQuestions = await loadQuestions();
    final answeredIds = await getAnsweredQuestionIds();
    return allQuestions.where((q) => !answeredIds.contains(q.id)).toList();
  }

  static Future<List<Map<String, dynamic>>> exportAnsweredQuestionStatistics() async {
    final stats = await getQuestionStatistics();
    final List<Map<String, dynamic>> exportedData = [];

    stats.forEach((questionId, questionStats) {
      exportedData.add({
        'id': questionId,
        'correctCount': questionStats['correctCount'] ?? 0,
        'incorrectCount': questionStats['incorrectCount'] ?? 0,
      });
    });

    return exportedData;
  }

  static Future<void> importQuestionStatistics(String jsonString) async {
    final List<dynamic> decodedList = json.decode(jsonString);
    final Map<String, Map<String, int>> importedStats = {};

    for (var item in decodedList) {
      if (item is Map<String, dynamic> && item.containsKey('id') && item.containsKey('correctCount') && item.containsKey('incorrectCount')) {
        importedStats[item['id']] = {
          'correctCount': item['correctCount'],
          'incorrectCount': item['incorrectCount'],
        };
      }
    }
    await _saveQuestionStatistics(importedStats);
  }
}