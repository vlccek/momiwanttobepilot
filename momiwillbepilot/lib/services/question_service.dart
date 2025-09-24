import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:momiwillbepilot/models/question.dart';

class QuestionService {
  static Future<List<Question>> loadQuestions() async {
    final String response = await rootBundle.loadString('assets/unikatni_otazky_obohatene.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Question.fromJson(json)).toList();
  }
}
