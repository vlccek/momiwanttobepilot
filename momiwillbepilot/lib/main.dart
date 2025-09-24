import 'package:flutter/material.dart';
import 'package:momiwillbepilot/screens/detail_screen.dart';
import 'package:momiwillbepilot/services/question_service.dart'; // Import QuestionService
import 'package:momiwillbepilot/models.dart'; // This seems to be for CardItem and OptionItem

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
      print('Error loading questions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    // UceniScreen(), // This will be replaced
    Text(
      'Testy',
    ),
    Text(
      'Statistiky',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Momiwillbepilot'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: _selectedIndex == 0
                  ? UceniScreen(questions: _questions) // Pass questions to UceniScreen
                  : _widgetOptions.elementAt(_selectedIndex - 1), // Adjust index for other screens
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

// UceniScreen needs to be updated to accept questions
class UceniScreen extends StatelessWidget {
  final List<Question> questions; // Add this
  const UceniScreen({super.key, required this.questions}); // Add this

  final List<CardItem> cardItems = const [
    CardItem(id: 'vsechny-otazky', title: 'Všechny otázky'),
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
        OptionItem(id: '1-bod', title: '1 bodové otázky'),
      ],
    ),
    CardItem(
      id: 'podle-tematu',
      title: 'Podle tématu',
      options: [
        OptionItem(id: 'letecke-predpisy', title: 'Letecké předpisy'),
        OptionItem(id: 'lidska-vykonnost', title: 'Lidská výkonnost'),
        OptionItem(id: 'meteorologie', title: 'Meteorologie'),
        OptionItem(id: 'navigace', title: 'Navigace'),
        OptionItem(id: 'provozni-postupy', title: 'Provozní postupy'),
        OptionItem(id: 'letove-vykony-a-planovani', title: 'Letové výkony a plánování'),
        OptionItem(id: 'znalosti-letadel', title: 'Znalosti letadel'),
        OptionItem(id: 'principy-letu', title: 'Principy letu'),
        OptionItem(id: 'radiokomunikace', title: 'Radiokomunikace'),
      ],
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: cardItems.length,
      itemBuilder: (context, index) {
        final item = cardItems[index];
        if (item.options.isEmpty) {
          return Card(
            child: InkWell(
              onTap: () {
                List<Question> filteredQuestions;
                if (item.id == 'vsechny-otazky') {
                  filteredQuestions = questions;
                } else {
                  filteredQuestions = questions.where((q) => q.category == item.title).toList();
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
                title: Text(item.title),
              ),
            ),
          );
        }  else {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...item.options.map(
                    (option) => InkWell(
                      onTap: () {
                        final filteredQuestions = questions.where((q) => q.category == option.title).toList();

                        if (filteredQuestions.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetailScreen(id: option.id, title: option.title, questions: filteredQuestions)),
                          );
                        }
                      },
                      child: ListTile(
                        leading: Icon(_getIconForTitle(option.title)),
                        title: Text(option.title),
                      ),
                    ),
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