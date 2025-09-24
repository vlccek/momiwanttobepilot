import 'package:flutter/material.dart';
import 'package:momiwillbepilot/models/question.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswered,
    this.onNextQuestion, // Add this
  });

  final Question question;
  final Function(bool isCorrect) onAnswered;
  final VoidCallback? onNextQuestion; // Add this

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  int? _selectedAnswerIndex;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.text,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...widget.question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _selectedAnswerIndex == index;
              final isCorrectOption = index == widget.question.correctAnswerIndex;

              Color? tileColor;
              if (_answered) {
                if (isCorrectOption) {
                  tileColor = Colors.green.shade100;
                } else if (isSelected) {
                  tileColor = Colors.red.shade100;
                }
              } else if (isSelected) {
                tileColor = Colors.blue.shade100;
              }


              return ListTile(
                tileColor: tileColor,
                title: Text(option),
                onTap: _answered
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswerIndex = index;
                          _answered = true;
                        });
                        final bool isCorrect = index == widget.question.correctAnswerIndex;
                        widget.onAnswered(isCorrect);
                      },
              );
            }),
            if (_answered && _selectedAnswerIndex != widget.question.correctAnswerIndex)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explanation:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(widget.question.explanation),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: widget.onNextQuestion, // Use the new callback
                      child: const Text('Next Question'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
