
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:momiwillbepilot/models/question.dart';
import 'package:momiwillbepilot/components/test_question_widget.dart';
import 'package:momiwillbepilot/screens/test_results_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key, required this.questions});

  final List<Question> questions;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _isTestInProgress = false;
  List<Question> _testQuestions = [];
  Map<String, int> _userAnswers = {}; // question.id -> selectedIndex
  Timer? _timer;
  int _timeLeftInSeconds = 3600; // 1 hour
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  void _startTest() {
    final threePointQuestions = widget.questions.where((q) => q.points == 3).toList();
    final onePointQuestions = widget.questions.where((q) => q.points == 1).toList();

    threePointQuestions.shuffle();
    onePointQuestions.shuffle();

    final testQuestions = [
      ...threePointQuestions.take(26),
      ...onePointQuestions.take(16),
    ];
    testQuestions.shuffle();

    _pageController.dispose();
    _pageController = PageController();

    setState(() {
      _testQuestions = testQuestions;
      _isTestInProgress = true;
      _userAnswers = <String, int>{};
      _timeLeftInSeconds = 3600;
      _currentPage = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeftInSeconds > 0) {
        setState(() {
          _timeLeftInSeconds--;
        });
      } else {
        _finishTest();
      }
    });
  }

  void _finishTest() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultsScreen(
          questions: _testQuestions,
          userAnswers: _userAnswers,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isTestInProgress = false);
      }
    });
  }

  void _onAnswered(Question question, int selectedIndex) {
    setState(() {
      _userAnswers[question.id] = selectedIndex;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTestInProgress) {
      return Center(
        child: ElevatedButton(
          onPressed: _startTest,
          child: const Text('Začít test'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Otázka ${_currentPage + 1}/${_testQuestions.length} - Čas: ${_timeLeftInSeconds ~/ 60}:${(_timeLeftInSeconds % 60).toString().padLeft(2, '0')}'),
        actions: [
          TextButton(
            onPressed: _finishTest,
            child: const Text('Ukončit test'),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _testQuestions.length,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final question = _testQuestions[index];
                return SingleChildScrollView(
                  child: TestQuestionWidget(
                    key: ValueKey(question.id),
                    question: question,
                    initialAnswerIndex: _userAnswers[question.id],
                    onAnswered: (selectedIndex) =>
                        _onAnswered(question, selectedIndex),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      : null,
                  child: const Text('Předchozí'),
                ),
                ElevatedButton(
                  onPressed: _currentPage < _testQuestions.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      : null,
                  child: const Text('Následující'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
