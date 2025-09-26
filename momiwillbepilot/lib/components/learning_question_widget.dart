import 'package:flutter/material.dart';
import 'package:momiwillbepilot/models/question.dart';

class LearningQuestionWidget extends StatefulWidget {
  const LearningQuestionWidget({
    super.key,
    required this.question,
    this.onAnswered,
    this.onNextQuestion,
    this.interactive = true,
    this.initialAnswerIndex,
  });

  final Question question;
  final Function(int selectedIndex)? onAnswered;
  final VoidCallback? onNextQuestion;
  final bool interactive;
  final int? initialAnswerIndex;

  @override
  State<LearningQuestionWidget> createState() => _LearningQuestionWidgetState();
}

class _LearningQuestionWidgetState extends State<LearningQuestionWidget> {
  int? _selectedAnswerIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswerIndex = widget.initialAnswerIndex;
    _answered = _selectedAnswerIndex != null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncorrectlyAnswered = _selectedAnswerIndex != null &&
        _selectedAnswerIndex != widget.question.correctAnswerIndex;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.question.text} (${widget.question.points} b.)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...widget.question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _selectedAnswerIndex == index;
              final isCorrectOption = index == widget.question.correctAnswerIndex;

              Color? tileColor;
              if (_answered || !widget.interactive) {
                if (isCorrectOption) {
                  tileColor = Colors.green.shade100;
                } else if (isSelected) {
                  tileColor = Colors.red.shade100;
                }
              }

              return ListTile(
                tileColor: tileColor,
                title: Text(option),
                onTap: (widget.interactive && !_answered)
                    ? () {
                        setState(() {
                          _selectedAnswerIndex = index;
                          _answered = true;
                        });
                        if (widget.onAnswered != null) {
                          widget.onAnswered!(index);
                        }
                      }
                    : null,
              );
            }),
            if ((_answered || !widget.interactive) && isIncorrectlyAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vysvětlení:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(widget.question.explanation),
                    if (widget.interactive)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton(
                          onPressed: widget.onNextQuestion,
                          child: const Text('Další otázka'),
                        ),
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
