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
    final options = json['options'];
    List<String> optionsList;
    if (options is Map) {
      optionsList = [
        options['option_a'] ?? '',
        options['option_b'] ?? '',
        options['option_c'] ?? '',
      ];
    } else if (options is List) {
      optionsList = List<String>.from(options);
    } else {
      optionsList = [];
    }

    int correctAnswerIndex;
    if (json.containsKey('correct_option')) {
      final String correctOptionKey = json['correct_option'];
      correctAnswerIndex = ['A', 'B', 'C'].indexOf(correctOptionKey);
    } else if (json.containsKey('correctAnswerIndex')) {
      correctAnswerIndex = json['correctAnswerIndex'];
    } else {
      correctAnswerIndex = 0;
    }

    return Question(
      id: json['question_id'] ?? json['id'] ?? '',
      text: json['question_text'] ?? json['text'] ?? '',
      options: optionsList,
      correctAnswerIndex: correctAnswerIndex,
      points: json['points'] ?? 0,
      occurrenceCount: json['occurrence_count'] ?? json['occurrenceCount'] ?? 0,
      lastOccurrence: json['last_seen'] ?? json['lastOccurrence'] ?? '',
      firstOccurrence: json['first_seen'] ?? json['firstOccurrence'] ?? '',
      category: json['category'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': id,
      'question_text': text,
      'options': {
        'option_a': options.isNotEmpty ? options[0] : '',
        'option_b': options.length > 1 ? options[1] : '',
        'option_c': options.length > 2 ? options[2] : '',
      },
      'correct_option': ['A', 'B', 'C'][correctAnswerIndex],
      'points': points,
      'occurrence_count': occurrenceCount,
      'last_seen': lastOccurrence,
      'first_seen': firstOccurrence,
      'category': category,
      'explanation': explanation,
    };
  }
}
