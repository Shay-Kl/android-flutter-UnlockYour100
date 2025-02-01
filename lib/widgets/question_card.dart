import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final void Function()? onTap;
  final bool? checkboxValue;
  final void Function(bool?)? onCheckboxChanged;
  final EdgeInsetsGeometry margin;

  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
    this.checkboxValue,
    this.onCheckboxChanged,
    this.margin = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      margin: margin,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.inverseSurface,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Remove inner border radius
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Remove inner border radius
          ),
          title: Row(
            children: [
              if (checkboxValue != null)
                Checkbox(
                  value: checkboxValue,
                  onChanged: onCheckboxChanged,
                ),
              Expanded(child: Text(question.question)),
            ],
          ),
          children: [
            // Explanation
            if (question.explanation.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  question.explanation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            // Correct Answer
            ListTile(
              dense: true,
              leading:
                  Icon(Icons.check_circle_outline, color: colorScheme.primary),
              title: Text(question.correctAnswer),
            ),
            // Wrong Answers
            ...question.wrongAnswers.map((answer) => ListTile(
                  dense: true,
                  leading: Icon(Icons.radio_button_unchecked,
                      color: colorScheme.outline),
                  title: Text(answer),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
