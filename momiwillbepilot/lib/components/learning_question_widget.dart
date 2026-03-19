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

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.question.points} body',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.question.category.isNotEmpty)
                        Text(
                          widget.question.category,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.question.text,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswerIndex == index;
            final isCorrectOption = index == widget.question.correctAnswerIndex;
            final String letter = String.fromCharCode(65 + index); // A, B, C

            Color borderColor = Colors.transparent;
            Color bgColor = Theme.of(context).colorScheme.surface;
            Color letterBgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
            Color letterTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

            if (_answered || !widget.interactive) {
              if (isCorrectOption) {
                bgColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green.withOpacity(0.5);
                letterBgColor = Colors.green;
                letterTextColor = Colors.white;
              } else if (isSelected) {
                bgColor = Colors.red.withOpacity(0.1);
                borderColor = Colors.red.withOpacity(0.5);
                letterBgColor = Colors.red;
                letterTextColor = Colors.white;
              }
            } else if (isSelected) {
              borderColor = Theme.of(context).colorScheme.primary;
              bgColor = Theme.of(context).colorScheme.primary.withOpacity(0.05);
              letterBgColor = Theme.of(context).colorScheme.primary;
              letterTextColor = Colors.white;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: InkWell(
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
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: [
                      if (isSelected && !_answered)
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: letterBgColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: TextStyle(
                            color: letterTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if ((_answered || !widget.interactive) && isIncorrectlyAnswered)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, 
                             color: Theme.of(context).colorScheme.onSecondaryContainer),
                        const SizedBox(width: 8),
                        Text(
                          'Vysvětlení',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.question.explanation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    if (widget.interactive)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: FilledButton.icon(
                          onPressed: widget.onNextQuestion,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Další otázka'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
