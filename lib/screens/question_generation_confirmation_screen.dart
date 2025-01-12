import 'package:flutter/material.dart';
import '../models/question.dart';

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
          return Card.outlined(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ExpansionTile(
              title: Row(
                children: [
                  Checkbox(
                    value: _selectedIndices.contains(index),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedIndices.add(index);
                        } else {
                          _selectedIndices.remove(index);
                        }
                      });
                    },
                  ),
                  Expanded(child: Text(question.question)),
                ],
              ),
              children: question.answers
                  .map(
                    (answer) => ListTile(
                      dense: true,
                      leading: const SizedBox(width: 32),
                      title: Text(
                        answer,
                        style: TextStyle(
                          color: answer == question.correctAnswer
                              ? Colors.green
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
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
            FilledButton(
              onPressed: () {
                final selectedQuestions = <Question>[];
                for (var i in _selectedIndices) {
                  selectedQuestions.add(widget.questions[i]);
                }
                Navigator.pop(context, selectedQuestions);
              },
              child: const Text('Add to Set'),
            ),
          ],
        ),
      ),
    );
  }
}
