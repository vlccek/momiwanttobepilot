
import 'package:flutter/material.dart';
import 'package:momiwillbepilot/models/question.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:momiwillbepilot/components/learning_question_widget.dart';
import 'package:momiwillbepilot/main.dart';
import 'package:confetti/confetti.dart';

class TestResultsScreen extends StatefulWidget {
  const TestResultsScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  final List<Question> questions;
  final Map<String, int> userAnswers;

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  String _filter = 'all'; // all, correct, incorrect, unanswered
  String _pointFilter = 'all'; // all, 3, 1
  String _categoryFilter = 'all';
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Check if passed and trigger confetti
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int score = 0;
      for (var q in widget.questions) {
        if (widget.userAnswers.containsKey(q.id) &&
            widget.userAnswers[q.id] == q.correctAnswerIndex) {
          score += q.points;
        }
      }
      if (score >= 75) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int correctAnswers = 0;
    int incorrectAnswers = 0;
    int unanswered = 0;

    for (var q in widget.questions) {
      if (widget.userAnswers.containsKey(q.id)) {
        if (widget.userAnswers[q.id] == q.correctAnswerIndex) {
          correctAnswers++;
        } else {
          incorrectAnswers++;
        }
      } else {
        unanswered++;
      }
    }

    int score = 0;
    for (var q in widget.questions) {
      if (widget.userAnswers.containsKey(q.id) &&
          widget.userAnswers[q.id] == q.correctAnswerIndex) {
        score += q.points;
      }
    }

    final percentage = (score / 94 * 100);
    final isPassed = score >= 75;

    final data = [
      ChartData('Správně', correctAnswers, Colors.green),
      ChartData('Nesprávně', incorrectAnswers, Colors.red),
      ChartData('Neodpovězeno', unanswered, Colors.grey),
    ];

    final series = [
      charts.Series<ChartData, String>(
        id: 'Results',
        domainFn: (ChartData sales, _) => sales.label,
        measureFn: (ChartData sales, _) => sales.value,
        colorFn: (ChartData sales, _) =>
            charts.ColorUtil.fromDartColor(sales.color),
        data: data,
        labelAccessorFn: (ChartData row, _) => '${row.value}',
      ),
    ];

    final categories = ['all', ...widget.questions.map((q) => q.category).toSet()];

    List<Question> filteredQuestions = widget.questions.where((q) {
      final answered = widget.userAnswers.containsKey(q.id);
      final correct =
          answered && widget.userAnswers[q.id] == q.correctAnswerIndex;

      bool passesFilter = false;
      if (_filter == 'all') {
        passesFilter = true;
      } else if (_filter == 'correct') {
        passesFilter = answered && correct;
      } else if (_filter == 'incorrect') {
        passesFilter = answered && !correct;
      } else if (_filter == 'unanswered') {
        passesFilter = !answered;
      }

      final passesPointFilter =
          (_pointFilter == 'all') || (_pointFilter == q.points.toString());
      
      final passesCategoryFilter = (_categoryFilter == 'all') || (_categoryFilter == q.category);

      return passesFilter && passesPointFilter && passesCategoryFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Výsledky testu - Skóre: $score / 94'),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: isPassed ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Text(
                      isPassed ? 'PROSPĚL(A)' : 'NEPROSPĚL(A)',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isPassed ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isPassed) 
                      const Text('JUPii! Skvělý výkon!', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 150,
                child: charts.PieChart(
                  series,
                  animate: true,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Všechny body'),
                      selected: _pointFilter == 'all',
                      onSelected: (selected) {
                        if (selected) setState(() => _pointFilter = 'all');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('3 body'),
                      selected: _pointFilter == '3',
                      onSelected: (selected) {
                        if (selected) setState(() => _pointFilter = '3');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('1 bod'),
                      selected: _pointFilter == '1',
                      onSelected: (selected) {
                        if (selected) setState(() => _pointFilter = '1');
                      },
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Vše'),
                      selected: _filter == 'all',
                      onSelected: (selected) {
                        if (selected) setState(() => _filter = 'all');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Správně'),
                      selected: _filter == 'correct',
                      onSelected: (selected) {
                        if (selected) setState(() => _filter = 'correct');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Špatně'),
                      selected: _filter == 'incorrect',
                      onSelected: (selected) {
                        if (selected) setState(() => _filter = 'incorrect');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Nezodpovězeno'),
                      selected: _filter == 'unanswered',
                      onSelected: (selected) {
                        if (selected) setState(() => _filter = 'unanswered');
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _categoryFilter,
                  items: categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat == 'all' ? 'Všechny kategorie' : cat),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _categoryFilter = val);
                  },
                ),
              ),
              Expanded(
                child: SelectionArea(
                  child: ListView.builder(
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = filteredQuestions[index];
                      return LearningQuestionWidget(
                        question: question,
                        interactive: false,
                        initialAnswerIndex: widget.userAnswers[question.id],
                        manualNextOnCorrect: settingsService.manualNextOnCorrect,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MyHomePage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Zpět na hlavní obrazovku'),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ChartData {
  final String label;
  final int value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}
