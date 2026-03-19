import 'dart:math';
import 'package:flutter/material.dart';
import 'package:momiwillbepilot/models/question.dart';
import 'package:momiwillbepilot/services/question_service.dart';
import 'package:momiwillbepilot/models/ui_models.dart';
import 'package:momiwillbepilot/screens/detail_screen.dart';

class UceniScreen extends StatefulWidget {
  final List<Question> questions;
  const UceniScreen({super.key, required this.questions});

  @override
  State<UceniScreen> createState() => _UceniScreenState();
}

class _UceniScreenState extends State<UceniScreen> {
  List<Question> _shuffledQuestions = [];
  int _neznameCount = 0;
  int _potizistiCount = 0;

  @override
  void initState() {
    super.initState();
    _prepareQuestions();
    _calculateDynamicCategoryCounts();
  }

  Future<void> _calculateDynamicCategoryCounts() async {
    final answeredIds = await QuestionService.getAnsweredQuestionIds();
    final incorrectlyAnsweredIds = await QuestionService.getIncorrectlyAnsweredQuestionIds();
    if (mounted) {
      setState(() {
        _neznameCount = widget.questions.where((q) => !answeredIds.contains(q.id)).length;
        _potizistiCount = widget.questions.where((q) => incorrectlyAnsweredIds.contains(q.id)).length;
      });
    }
  }

  Future<void> _prepareQuestions() async {
    final incorrectlyAnsweredIds = await QuestionService.getIncorrectlyAnsweredQuestionIds();
    final weightedQuestions = <Question>[];

    for (var q in widget.questions) {
      weightedQuestions.add(q);
      if (incorrectlyAnsweredIds.contains(q.id)) {
        weightedQuestions.add(q);
        weightedQuestions.add(q);
      }
    }

    setState(() {
      _shuffledQuestions = weightedQuestions.toList()..shuffle(Random());
    });
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Všechny otázky': return Icons.all_inclusive;
      case 'Neznáme otázky': return Icons.help_outline;
      case 'Potížišti': return Icons.warning_amber_outlined;
      case 'Označené': return Icons.bookmark_border;
      case 'Letecké předpisy a legislativa':
      case 'Letecké předpisy': return Icons.gavel;
      case 'Lidská výkonnost, zdravotní způsobilost a první pomoc':
      case 'Lidská výkonnost': return Icons.accessibility_new;
      case 'Meteorologie': return Icons.cloud;
      case 'Navigace a letové přístroje':
      case 'Navigace': return Icons.navigation;
      case 'Provozní postupy a bezpečnost':
      case 'Provozní postupy': return Icons.list_alt;
      case 'Letové výkony a plánování': return Icons.flight_takeoff;
      case 'Všeobecné znalosti letadel':
      case 'Znalosti letadel': return Icons.airplane_ticket;
      case 'Principy letu a aerodynamika':
      case 'Principy letu': return Icons.flight;
      case 'Komunikace a letištní provoz':
      case 'Radiokomunikace': return Icons.wifi_tethering;
      case 'Specifické typy letadel': return Icons.airplanemode_active;
      default: return Icons.label;
    }
  }

  void _navigateToDetailScreen(String id, String title, List<Question> questions) {
    if (questions.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(id: id, title: title, questions: questions),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<CardItem> cardItems = [
      const CardItem(id: 'vsechny-otazky', title: 'Všechny otázky'),
      CardItem(
        id: 'dynamicke-kategorie',
        title: 'Dynamické kategorie',
        options: [
          OptionItem(id: 'nezname-otazky', title: 'Neznáme otázky'),
          OptionItem(id: 'potizisti', title: 'Potížišti'),
          OptionItem(id: 'oznacene', title: 'Označené'),
        ],
      ),
      CardItem(
        id: 'body-kategorie',
        title: 'Bodové kategorie',
        options: [
          OptionItem(id: '3-body', title: '3 bodové otázky'),
          OptionItem(id: '1-bod', title: '1 bodové'),
          OptionItem(id: '0-bodu', title: '0 bodové'),
        ],
      ),
    ];

    final uniqueCategories = widget.questions.map((q) => q.category).toSet().toList();
    final thematicCardItem = CardItem(
      id: 'podle-tematu',
      title: 'Podle tématu',
      options: uniqueCategories
          .map((category) => OptionItem(id: category, title: category))
          .toList(),
    );

    final allCardItems = [...cardItems, thematicCardItem];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: allCardItems.length,
      itemBuilder: (context, index) {
        final item = allCardItems[index];
        
        if (item.options.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildCategoryCard(
              title: item.title,
              subtitle: '${widget.questions.length} otázek',
              icon: _getIconForTitle(item.title),
              onTap: () {
                List<Question> filteredQuestions = item.id == 'vsechny-otazky' 
                    ? _shuffledQuestions 
                    : _shuffledQuestions.where((q) => q.category == item.title).toList();
                _navigateToDetailScreen(item.id, item.title, filteredQuestions);
              },
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 0, 12),
              child: Text(
                item.title.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ...item.options.map((option) {
              int count = 0;
              if (option.id == 'nezname-otazky') count = _neznameCount;
              else if (option.id == 'potizisti') count = _potizistiCount;
              else if (option.id == 'oznacene') count = 0;
              else if (option.id == '3-body') count = widget.questions.where((q) => q.points == 3).length;
              else if (option.id == '1-bod') count = widget.questions.where((q) => q.points == 1).length;
              else if (option.id == '0-bodu') count = widget.questions.where((q) => q.points == 0).length;
              else count = widget.questions.where((q) => q.category == option.title).length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildCategoryCard(
                  title: option.title,
                  subtitle: '$count otázek',
                  icon: _getIconForTitle(option.title),
                  onTap: () async {
                    List<Question> filteredQuestions = [];
                    if (option.id == 'nezname-otazky') {
                      final answeredIds = await QuestionService.getAnsweredQuestionIds();
                      if (!mounted) return;
                      filteredQuestions = widget.questions.where((q) => !answeredIds.contains(q.id)).toList();
                      filteredQuestions.shuffle(Random());
                    } else if (option.id == 'potizisti') {
                      final incorrectlyAnsweredIds = await QuestionService.getIncorrectlyAnsweredQuestionIds();
                      if (!mounted) return;
                      filteredQuestions = widget.questions.where((q) => incorrectlyAnsweredIds.contains(q.id)).toList();
                      filteredQuestions.shuffle(Random());
                    } else if (option.id == '3-body') {
                      filteredQuestions = _shuffledQuestions.where((q) => q.points == 3).toList();
                    } else if (option.id == '1-bod') {
                      filteredQuestions = _shuffledQuestions.where((q) => q.points == 1).toList();
                    } else if (option.id == '0-bodu') {
                      filteredQuestions = _shuffledQuestions.where((q) => q.points == 0).toList();
                    } else {
                      filteredQuestions = _shuffledQuestions.where((q) => q.category == option.title).toList();
                    }
                    if (!mounted) return;
                    _navigateToDetailScreen(option.id, option.title, filteredQuestions);
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }
}
