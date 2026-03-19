import 'package:momiwillbepilot/models/question.dart';

class TestResult {
  final String id;
  final DateTime timestamp;
  final int score;
  final int totalPoints;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unanswered;
  final List<Question> questions;
  final Map<String, int> userAnswers; // question.id -> selectedIndex

  TestResult({
    required this.id,
    required this.timestamp,
    required this.score,
    required this.totalPoints,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unanswered,
    required this.questions,
    required this.userAnswers,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      score: json['score'],
      totalPoints: json['totalPoints'],
      correctAnswers: json['correctAnswers'],
      incorrectAnswers: json['incorrectAnswers'],
      unanswered: json['unanswered'],
      questions: (json['questions'] as List)
          .map((qJson) => Question.fromJson(qJson))
          .toList(),
      userAnswers: Map<String, int>.from(json['userAnswers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'score': score,
      'totalPoints': totalPoints,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'unanswered': unanswered,
      'questions': questions.map((q) => q.toJson()).toList(),
      'userAnswers': userAnswers,
    };
  }
}
