import 'dart:async';
import 'package:flutter/material.dart';
import 'package:momiwillbepilot/models/question.dart';
import 'package:momiwillbepilot/components/test_question_widget.dart';
import 'package:momiwillbepilot/screens/test_results_screen.dart';
import 'package:momiwillbepilot/models/test_result.dart';
import 'package:momiwillbepilot/services/test_result_service.dart';
import 'package:momiwillbepilot/components/learning_question_widget.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key, required this.questions});

  final List<Question> questions;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _isTestInProgress = false;
  List<Question> _testQuestions = [];
  Map<String, int> _userAnswers = {};
  Timer? _timer;
  int _timeLeftInSeconds = 3600;
  PageController _pageController = PageController();
  int _currentPage = 0;
  List<TestResult> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _isLoadingHistory = true);
    try {
      final history = await TestResultService.loadAllTestResults();
      if (mounted) {
        setState(() {
          _history = history.reversed.toList();
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
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

  void _finishTest() async {
    _timer?.cancel();

    int correctAnswers = 0;
    int incorrectAnswers = 0;
    int unanswered = 0;
    int score = 0;
    int totalPossiblePoints = 0;

    for (var q in _testQuestions) {
      totalPossiblePoints += q.points;
      if (_userAnswers.containsKey(q.id)) {
        if (_userAnswers[q.id] == q.correctAnswerIndex) {
          correctAnswers++;
          score += q.points;
        } else {
          incorrectAnswers++;
        }
      } else {
        unanswered++;
      }
    }

    final testResult = TestResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      score: score,
      totalPoints: totalPossiblePoints,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      unanswered: unanswered,
      questions: List.from(_testQuestions),
      userAnswers: Map.from(_userAnswers),
    );

    await TestResultService.saveTestResult(testResult);
    await _loadHistory();

    if (!mounted) return;

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
    // Ultra-safe check for history to prevent Web crashes
    final dynamic h = _history;
    final bool hasHistory = h != null && h is List && h.isNotEmpty;
    final List<TestResult> safeHistory = hasHistory ? List<TestResult>.from(h) : [];

    if (!_isTestInProgress) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildNewTestCard(),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  'HISTORIE TESTŮ',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (hasHistory)
                  Text(
                    '${safeHistory.length} pokusů',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingHistory)
              const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ))
            else if (!hasHistory)
              _buildEmptyHistory()
            else
              ...safeHistory.map((result) => _buildHistoryCard(result)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${_currentPage + 1}/${_testQuestions.length} - ${(_timeLeftInSeconds ~/ 60)}:${(_timeLeftInSeconds % 60).toString().padLeft(2, '0')}'),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Ukončit test?'),
                  content: const Text('Opravdu chcete test ukončit a vyhodnotit?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Pokračovat')),
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                      _finishTest();
                    }, child: const Text('Ukončit')),
                  ],
                ),
              );
            },
            child: const Text('Vyhodnotit'),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _testQuestions.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final question = _testQuestions[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: TestQuestionWidget(
                    key: ValueKey(question.id),
                    question: question,
                    initialAnswerIndex: _userAnswers[question.id],
                    onAnswered: (selectedIndex) => _onAnswered(question, selectedIndex),
                  ),
                );
              },
            ),
          ),
          _buildTestNavigation(),
        ],
      ),
    );
  }

  Widget _buildNewTestCard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Nový cvičný test',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '42 otázek (26x 3b, 16x 1b)\nČasový limit: 60 minut',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _startTest,
              icon: const Icon(Icons.play_arrow),
              label: const Text('ZAČÍT TEST'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(TestResult result) {
    final percentage = (result.score / result.totalPoints * 100).toInt();
    final isPassed = percentage >= 75;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _viewTestReview(result),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (isPassed ? Colors.green : Colors.orange).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            '$percentage%',
            style: TextStyle(
              color: isPassed ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('${result.timestamp.day}. ${result.timestamp.month}. ${result.timestamp.year}'),
        subtitle: Text('Skóre: ${result.score}/${result.totalPoints} • ${result.correctAnswers} správně'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Zatím žádné testy',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
            onPressed: _currentPage > 0 
              ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn)
              : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text(
            'Otázka ${_currentPage + 1} z ${_testQuestions.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton.filledTonal(
            onPressed: _currentPage < _testQuestions.length - 1
              ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn)
              : null,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  void _viewTestReview(TestResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestReviewScreen(result: result),
      ),
    );
  }
}

class TestReviewScreen extends StatelessWidget {
  final TestResult result;
  const TestReviewScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prohlídka testu'),
      ),
      body: SelectionArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: result.questions.length,
          itemBuilder: (context, index) {
            final question = result.questions[index];
            final userAnswerIndex = result.userAnswers[question.id];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: LearningQuestionWidget(
                question: question,
                interactive: false,
                initialAnswerIndex: userAnswerIndex,
              ),
            );
          },
        ),
      ),
    );
  }
}
