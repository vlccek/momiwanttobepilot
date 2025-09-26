class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final int points;
  final int occurrenceCount;
  final String lastOccurrence;
  final String firstOccurrence;
  final String category;
  final String explanation;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.points,
    required this.occurrenceCount,
    required this.lastOccurrence,
    required this.firstOccurrence,
    required this.category,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final Map<String, String> moznostiMap = Map<String, String>.from(json['moznosti']);
    final List<String> optionsList = moznostiMap.values.toList();

    final String spravnaOdpovedKey = json['spravna_odpoved'];
    final String spravnaOdpovedText = moznostiMap[spravnaOdpovedKey]!;
    final int correctAnswerIndex = optionsList.indexOf(spravnaOdpovedText);

    return Question(
      id: json['hashid'],
      text: json['text_otazky'],
      options: optionsList,
      correctAnswerIndex: correctAnswerIndex,
      points: json['body'],
      occurrenceCount: json['pocet_vyskytu'],
      lastOccurrence: json['poslední_výskyt'],
      firstOccurrence: json['první_výskyt'],
      category: json['kategorie'],
      explanation: json['vysvetleni'],
    );
  }
}
