
import 'package:flutter/material.dart';
import 'package:momiwillbepilot/models/question.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:momiwillbepilot/components/learning_question_widget.dart';
import 'package:momiwillbepilot/main.dart';

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
      return passesFilter && passesPointFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Výsledky testu - Skóre: $score / 94'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: charts.PieChart(
              series,
              animate: true,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
          Expanded(
            child: ListView.builder(
              itemCount: filteredQuestions.length,
              itemBuilder: (context, index) {
                final question = filteredQuestions[index];
                return LearningQuestionWidget(
                  question: question,
                  interactive: false,
                  initialAnswerIndex: widget.userAnswers[question.id],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MyHomePage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Zpět na hlavní obrazovku'),
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
