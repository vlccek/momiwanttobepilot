import 'dart:math';

import 'package:flutter/material.dart';
import 'package:momiwillbepilot/screens/detail_screen.dart';
import 'package:momiwillbepilot/screens/settings_screen.dart';
import 'package:momiwillbepilot/screens/statistics_screen.dart';
import 'package:momiwillbepilot/services/question_service.dart'; // Import QuestionService
import 'package:momiwillbepilot/models.dart'; // This seems to be for CardItem and OptionItem
import 'package:momiwillbepilot/screens/test_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Question> _questions = []; // To store loaded questions
  bool _isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final loadedQuestions = await QuestionService.loadQuestions();
      setState(() {
        _questions = loadedQuestions;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error, e.g., show a snackbar or an error message
      // print('Error loading questions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      UceniScreen(questions: _questions),
      TestScreen(questions: _questions),
      const StatisticsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Momiwillbepilot (Beta)'),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Učení',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Testy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistiky',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}


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
        // Add incorrectly answered questions 2 more times to increase their weight
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
      case 'Všechny otázky':
        return Icons.all_inclusive;
      case 'Neznáme otázky':
        return Icons.help_outline;
      case 'Potížišti':
        return Icons.warning_amber_outlined;
      case 'Označené':
        return Icons.bookmark_border;
      case 'Letecké předpisy':
        return Icons.gavel;
      case 'Lidská výkonnost':
        return Icons.accessibility_new;
      case 'Meteorologie':
        return Icons.cloud;
      case 'Navigace':
        return Icons.navigation;
      case 'Provozní postupy':
        return Icons.list_alt;
      case 'Letové výkony a plánování':
        return Icons.flight_takeoff;
      case 'Znalosti letadel':
        return Icons.airplane_ticket;
      case 'Principy letu':
        return Icons.flight;
      case 'Radiokomunikace':
        return Icons.wifi_tethering;
      default:
        return Icons.label;
    }
  }

  void _navigateToDetailScreen(
      String id, String title, List<Question> questions) {
    if (questions.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            id: id,
            title: title,
            questions: questions,
          ),
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
      padding: const EdgeInsets.all(8.0),
      itemCount: allCardItems.length,
      itemBuilder: (context, index) {
        final item = allCardItems[index];
        if (item.options.isEmpty) {
          return Card(
            child: InkWell(
              onTap: () {
                List<Question> filteredQuestions;
                if (item.id == 'vsechny-otazky') {
                  filteredQuestions = _shuffledQuestions;
                } else {
                  filteredQuestions = _shuffledQuestions.where((q) => q.category == item.title).toList();
                }

                if (filteredQuestions.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailScreen(id: item.id, title: item.title, questions: filteredQuestions)),
                  );
                }
              },
              child: ListTile(
                leading: Icon(_getIconForTitle(item.title)),
                title: Text('${item.title} (${widget.questions.length})'),
              ),
            ),
          );
        } else {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...item.options.map(
                        (option) {
                      int count = 0;
                      if (option.id == 'nezname-otazky') {
                        count = _neznameCount;
                      } else if (option.id == 'potizisti') {
                        count = _potizistiCount;
                      } else if (option.id == 'oznacene') {
                        count = 0; // TODO: Implement marked questions
                      } else if (option.id == '3-body') {
                        count = widget.questions.where((q) => q.points == 3).length;
                      } else if (option.id == '1-bod') {
                        count = widget.questions.where((q) => q.points == 1).length;
                      } else {
                        count = widget.questions.where((q) => q.category == option.title).length;
                      }
                      return InkWell(
                        onTap: () async {
                          List<Question> filteredQuestions = [];
                          if (option.id == 'nezname-otazky') {
                            final answeredIds =
                            await QuestionService.getAnsweredQuestionIds();
                            if (!mounted) return;
                            filteredQuestions = widget.questions
                                .where((q) => !answeredIds.contains(q.id))
                                .toList();
                            filteredQuestions.shuffle(Random());
                          } else if (option.id == 'potizisti') {
                            final incorrectlyAnsweredIds = await QuestionService
                                .getIncorrectlyAnsweredQuestionIds();
                            if (!mounted) return;
                            filteredQuestions = widget.questions
                                .where((q) => incorrectlyAnsweredIds.contains(q.id))
                                .toList();
                            filteredQuestions.shuffle(Random());
                          } else if (option.id == 'oznacene') {
                            // TODO: Implement marked questions
                          } else if (option.id == '3-body') {
                            filteredQuestions = _shuffledQuestions
                                .where((q) => q.points == 3)
                                .toList();
                          } else if (option.id == '1-bod') {
                            filteredQuestions = _shuffledQuestions
                                .where((q) => q.points == 1)
                                .toList();
                          } else {
                            filteredQuestions = _shuffledQuestions
                                .where((q) => q.category == option.title)
                                .toList();
                          }

                          if (!mounted) return;

                          _navigateToDetailScreen(
                              option.id, option.title, filteredQuestions);
                        },
                        child: ListTile(
                          leading: Icon(_getIconForTitle(option.title)),
                          title: Text('${option.title} ($count)'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}