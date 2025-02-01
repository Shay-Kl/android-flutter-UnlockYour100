import 'package:flutter/material.dart';
import '../models/question.dart';
import 'mixed_text.dart'; // added MixedText import

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
          title: Row(
            children: [
              if (checkboxValue != null)
                Checkbox(
                  value: checkboxValue,
                  onChanged: onCheckboxChanged,
                ),
              Expanded(
                child: MixedText(
                  text: question.question,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          children: [
            // Correct Answer
            ListTile(
              dense: true,
              leading:
                  Icon(Icons.check_circle_outline, color: colorScheme.primary),
              title: MixedText(
                text: question.correctAnswer,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w400,
                fontSize: 15,
                textAlign: TextAlign.left,
              ),
            ),
            // Wrong Answers
            ...question.wrongAnswers.map((answer) => ListTile(
                  dense: true,
                  leading: Icon(Icons.radio_button_unchecked,
                      color: colorScheme.outline),
                  title: MixedText(
                    text: answer,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                    textAlign: TextAlign.left,
                  ),
                )),
            // Explanation
            if (question.explanation.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: MixedText(
                  text: question.explanation,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  textAlign: TextAlign.left,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
