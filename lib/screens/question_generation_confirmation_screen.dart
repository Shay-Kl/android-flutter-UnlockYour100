import 'package:flutter/material.dart';
import '../models/question.dart';
import '../widgets/question_card.dart';

class QuestionGenerationConfirmationScreen extends StatefulWidget {
  final List<Question> questions;

  const QuestionGenerationConfirmationScreen({
    super.key,
    required this.questions,
  });

  @override
  State<QuestionGenerationConfirmationScreen> createState() =>
      _QuestionGenerationConfirmationScreenState();
}

class _QuestionGenerationConfirmationScreenState
    extends State<QuestionGenerationConfirmationScreen> {
  late final Set<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndices =
        Set<int>.from(List<int>.generate(widget.questions.length, (i) => i));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generated Questions')),
      body: ListView.builder(
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final question = widget.questions[index];
          return QuestionCard(
            question: question,
            checkboxValue: _selectedIndices.contains(index),
            onCheckboxChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  _selectedIndices.add(index);
                } else {
                  _selectedIndices.remove(index);
                }
              });
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),  // Changed from 16 to 4
        child: Row(
          children: [
            const SizedBox(width: 20),  // Add this to match card margin
            Checkbox(
              value: _selectedIndices.length == widget.questions.length,
              tristate: true,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected ?? false) {
                    _selectedIndices.addAll(
                      List<int>.generate(widget.questions.length, (i) => i),
                    );
                  } else {
                    _selectedIndices.clear();
                  }
                });
              },
            ),
            const Text('Select All'),
            const Spacer(),
            Padding(  // Wrap FilledButton with Padding
              padding: const EdgeInsets.all(12),
              child: FilledButton(
                onPressed: () {
                  final selectedQuestions = <Question>[];
                  for (var i in _selectedIndices) {
                    selectedQuestions.add(widget.questions[i]);
                  }
                  Navigator.pop(context, selectedQuestions);
                },
                child: const Text('Add to Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
