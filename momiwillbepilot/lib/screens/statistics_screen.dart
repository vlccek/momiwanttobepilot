import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:momiwillbepilot/services/question_service.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:momiwillbepilot/models/test_result.dart';
import 'package:momiwillbepilot/services/test_result_service.dart';
import 'package:momiwillbepilot/services/platform_export_service.dart';
import 'package:file_picker/file_picker.dart';

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
  int _total0PointQuestions = 0;
  int _answered0PointQuestions = 0;
  List<TestResult> _testResults = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final allQuestions = await QuestionService.loadQuestions();
      final questionStatistics = await QuestionService.getQuestionStatistics();
      final loadedTestResults = await TestResultService.loadAllTestResults();

      final Map<String, int> answeredQuestionsByCategory = {};
      final Map<String, int> totalQuestionsByCategory = {};
      int total1PointQuestions = 0;
      int answered1PointQuestions = 0;
      int total3PointQuestions = 0;
      int answered3PointQuestions = 0;
      int total0PointQuestions = 0;
      int answered0PointQuestions = 0;
      int answeredCount = 0;

      for (var question in allQuestions) {
        totalQuestionsByCategory[question.category] = (totalQuestionsByCategory[question.category] ?? 0) + 1;
        if (question.points == 1) {
          total1PointQuestions++;
        } else if (question.points == 3) {
          total3PointQuestions++;
        } else if (question.points == 0) {
          total0PointQuestions++;
        }

        if (questionStatistics.containsKey(question.id)) {
          answeredCount++;
          answeredQuestionsByCategory[question.category] = (answeredQuestionsByCategory[question.category] ?? 0) + 1;
          if (question.points == 1) {
            answered1PointQuestions++;
          } else if (question.points == 3) {
            answered3PointQuestions++;
          } else if (question.points == 0) {
            answered0PointQuestions++;
          }
        }
      }

      if (mounted) {
        setState(() {
          _totalQuestions = allQuestions.length;
          _answeredQuestions = answeredCount;
          _answeredQuestionsByCategory = answeredQuestionsByCategory;
          _totalQuestionsByCategory = totalQuestionsByCategory;
          _total1PointQuestions = total1PointQuestions;
          _answered1PointQuestions = answered1PointQuestions;
          _total3PointQuestions = total3PointQuestions;
          _answered3PointQuestions = answered3PointQuestions;
          _total0PointQuestions = total0PointQuestions;
          _answered0PointQuestions = answered0PointQuestions;
          _testResults = loadedTestResults;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportResults() async {
    try {
      final allResults = await TestResultService.loadAllTestResults();
      final String jsonString = await TestResultService.exportTestResults(allResults);

      await PlatformExportService.exportJson(jsonString, 'exported_test_results.json');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Výsledky exportovány.'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba při exportu: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _importResults() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        String jsonString;
        if (kIsWeb) {
          jsonString = utf8.decode(result.files.single.bytes!);
        } else {
          final file = File(result.files.single.path!);
          jsonString = await file.readAsString();
        }
        
        if (jsonString.isNotEmpty) {
          await TestResultService.importTestResults(jsonString);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Výsledky importovány.'), behavior: SnackBarBehavior.floating),
            );
            _loadStatistics();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba při importu: $e'), behavior: SnackBarBehavior.floating),
        );
      }
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
                  _buildStatCard('Celkový počet otázek', _totalQuestions.toString(), Icons.quiz_outlined),
                  const SizedBox(height: 12),
                  _buildStatCard('Zodpovězené otázky', _answeredQuestions.toString(), Icons.check_circle_outline),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _totalQuestions > 0 ? _answeredQuestions / _totalQuestions : 0,
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Zodpovězené otázky podle kategorií', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _answeredQuestionsByCategory.isEmpty
                        ? const Center(child: Text('Žádné zodpovězené otázky v kategoriích.'))
                        : _buildPieChart(),
                  ),
                  const SizedBox(height: 32),
                  Text('Průběh podle kategorií', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _totalQuestionsByCategory.isEmpty
                      ? const Center(child: Text('Žádné otázky k zobrazení.'))
                      : _buildCategoryProgress(),
                  const SizedBox(height: 32),
                  Text('Průběh podle bodů', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildPointProgress(),
                  const SizedBox(height: 32),
                  Text('Historie testů', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _testResults.isEmpty
                      ? const Center(child: Text('Žádné dokončené testy.'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _testResults.length,
                          itemBuilder: (context, index) {
                            final result = _testResults[index];
                            final percentageValue = result.totalPoints > 0 ? (result.score / result.totalPoints * 100) : 0;
                            final percentage = percentageValue.toStringAsFixed(0);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: percentageValue >= 75 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  child: Text('$percentage%', style: TextStyle(fontSize: 12, color: percentageValue >= 75 ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                                ),
                                title: Text('Test ${result.timestamp.day}.${result.timestamp.month}. ${result.timestamp.hour}:${result.timestamp.minute.toString().padLeft(2, '0')}'),
                                subtitle: Text('Skóre: ${result.score}/${result.totalPoints} | Správně: ${result.correctAnswers}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {},
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _exportResults,
                          icon: const Icon(Icons.upload_outlined),
                          label: const Text('Exportovat'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importResults,
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Importovat'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(category, style: Theme.of(context).textTheme.titleSmall)),
                  Text('$answered/$total', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? answered / total : 0,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPointProgress() {
    final t0 = (_total0PointQuestions as dynamic) ?? 0;
    final a0 = (_answered0PointQuestions as dynamic) ?? 0;
    final t1 = (_total1PointQuestions as dynamic) ?? 0;
    final a1 = (_answered1PointQuestions as dynamic) ?? 0;
    final t3 = (_total3PointQuestions as dynamic) ?? 0;
    final a3 = (_answered3PointQuestions as dynamic) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPointItem('0 bodové otázky', a0, t0),
        _buildPointItem('1 bodové otázky', a1, t1),
        _buildPointItem('3 bodové otázky', a3, t3),
      ],
    );
  }

  Widget _buildPointItem(String label, int answered, int total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text('$answered/$total', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? answered / total : 0,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryFriction {
  final String category;
  final int answeredCount;

  CategoryFriction(this.category, this.answeredCount);
}
