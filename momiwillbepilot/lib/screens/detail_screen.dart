import 'package:flutter/material.dart';
import 'package:momiwillbepilot/components/question_widget.dart';
import 'package:momiwillbepilot/models/question.dart';
import 'package:momiwillbepilot/services/question_service.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final List<Question> questions; // Changed to List<Question>

  const DetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.questions, // Changed
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late List<Question> _allQuestions;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _allQuestions = widget.questions; // Initialize with the passed list
  }

  void _moveToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _allQuestions.length - 1) {
        _currentQuestionIndex++;
      } else {
        // All questions answered, navigate back or show completion screen
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _allQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: QuestionWidget(
          key: ValueKey(currentQuestion.text),
          question: currentQuestion,
          onAnswered: (isCorrect) {
            QuestionService.recordAnswer(currentQuestion.id, isCorrect);
            if (isCorrect) {
              QuestionService.removeIncorrectlyAnsweredQuestionId(currentQuestion.id);
              _moveToNextQuestion();
            } else {
              // If incorrect, QuestionWidget will show explanation and its own 'Next Question' button.
              // The 'Next Question' button will call onNextQuestion.
            }
          },
          onNextQuestion: _moveToNextQuestion,
        ),
      ),
    );
  }
}
