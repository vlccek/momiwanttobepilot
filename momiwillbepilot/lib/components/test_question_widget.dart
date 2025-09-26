import 'package:flutter/material.dart';
import 'package:momiwillbepilot/models/question.dart';

class TestQuestionWidget extends StatefulWidget {
  const TestQuestionWidget({
    super.key,
    required this.question,
    required this.onAnswered,
    this.initialAnswerIndex,
  });

  final Question question;
  final Function(int selectedIndex) onAnswered;
  final int? initialAnswerIndex;

  @override
  State<TestQuestionWidget> createState() => _TestQuestionWidgetState();
}

class _TestQuestionWidgetState extends State<TestQuestionWidget> {
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _selectedAnswerIndex = widget.initialAnswerIndex;
  }

  @override
  Widget build(BuildContext context) {
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

              Color? tileColor;
              if (isSelected) {
                tileColor = Colors.blue.shade100;
              }

              return ListTile(
                tileColor: tileColor,
                title: Text(option),
                onTap: () {
                  setState(() {
                    _selectedAnswerIndex = index;
                  });
                  widget.onAnswered(index);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
