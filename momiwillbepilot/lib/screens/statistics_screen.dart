import 'package:flutter/material.dart';

import 'package:momiwillbepilot/services/question_service.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _totalQuestions = 0;
  int _answeredQuestions = 0;
  bool _isLoading = true;
  Map<String, int> _answeredQuestionsByCategory = {};
  Map<String, int> _totalQuestionsByCategory = {};
  int _total1PointQuestions = 0;
  int _answered1PointQuestions = 0;
  int _total3PointQuestions = 0;
  int _answered3PointQuestions = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final allQuestions = await QuestionService.loadQuestions();
      final questionStatistics = await QuestionService.getQuestionStatistics();

      final Map<String, int> answeredQuestionsByCategory = {};
      final Map<String, int> totalQuestionsByCategory = {};
      int total1PointQuestions = 0;
      int answered1PointQuestions = 0;
      int total3PointQuestions = 0;
      int answered3PointQuestions = 0;
      int answeredCount = 0;

      for (var question in allQuestions) {
        totalQuestionsByCategory[question.category] = (totalQuestionsByCategory[question.category] ?? 0) + 1;
        if (question.points == 1) {
          total1PointQuestions++;
        }
        if (question.points == 3) {
          total3PointQuestions++;
        }

        if (questionStatistics.containsKey(question.id)) {
          answeredCount++;
          answeredQuestionsByCategory[question.category] = (answeredQuestionsByCategory[question.category] ?? 0) + 1;
          if (question.points == 1) {
            answered1PointQuestions++;
          }
          if (question.points == 3) {
            answered3PointQuestions++;
          }
        }
      }

      setState(() {
        _totalQuestions = allQuestions.length;
        _answeredQuestions = answeredCount;
        _answeredQuestionsByCategory = answeredQuestionsByCategory;
        _totalQuestionsByCategory = totalQuestionsByCategory;
        _total1PointQuestions = total1PointQuestions;
        _answered1PointQuestions = answered1PointQuestions;
        _total3PointQuestions = total3PointQuestions;
        _answered3PointQuestions = answered3PointQuestions;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Celkový počet otázek: $_totalQuestions', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Počet zodpovězených otázek: $_answeredQuestions', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _totalQuestions > 0 ? _answeredQuestions / _totalQuestions : 0,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 32),
                  Text('Zodpovězené otázky podle kategorií', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _answeredQuestionsByCategory.isEmpty
                        ? const Center(child: Text('Žádné zodpovězené otázky v kategoriích.'))
                        : _buildPieChart(),
                  ),
                  const SizedBox(height: 32),
                  Text('Průběh podle kategorií', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _totalQuestionsByCategory.isEmpty
                      ? const Center(child: Text('Žádné otázky k zobrazení.'))
                      : _buildCategoryProgress(),
                  const SizedBox(height: 32),
                  Text('Průběh podle bodů', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _buildPointProgress(),
                ],
              ),
            ),
          );
  }

  Widget _buildPieChart() {
    final List<CategoryFriction> data = _answeredQuestionsByCategory.entries.map((entry) {
      final category = entry.key;
      final answeredCount = entry.value;
      return CategoryFriction(category, answeredCount);
    }).toList();

    final series = [
      charts.Series<CategoryFriction, String>(
        id: 'AnsweredQuestions',
        domainFn: (CategoryFriction friction, _) => friction.category,
        measureFn: (CategoryFriction friction, _) => friction.answeredCount,
        data: data,
        labelAccessorFn: (CategoryFriction row, _) => '${row.category}: ${row.answeredCount}',
      ),
    ];

    return charts.PieChart<String>(
      series,
      animate: true,
      defaultRenderer: charts.ArcRendererConfig(
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.auto,
          )
        ],
      ),
    );
  }

  Widget _buildCategoryProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _totalQuestionsByCategory.keys.map((category) {
        final total = _totalQuestionsByCategory[category]!;
        final answered = _answeredQuestionsByCategory[category] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$category ($answered/$total)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: total > 0 ? answered / total : 0,
                minHeight: 8,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPointProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1 bodové otázky ($_answered1PointQuestions/$_total1PointQuestions)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _total1PointQuestions > 0 ? _answered1PointQuestions / _total1PointQuestions : 0,
                minHeight: 8,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('3 bodové otázky ($_answered3PointQuestions/$_total3PointQuestions)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _total3PointQuestions > 0 ? _answered3PointQuestions / _total3PointQuestions : 0,
                minHeight: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryFriction {
  final String category;
  final int answeredCount;

  CategoryFriction(this.category, this.answeredCount);
}