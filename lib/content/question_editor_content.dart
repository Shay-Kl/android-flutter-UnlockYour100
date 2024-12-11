import 'package:flutter/material.dart';

class QuestionEditorContent extends StatelessWidget {
  const QuestionEditorContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Editor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Question Title',
              ),
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Question Description',
              ),
              maxLines: null,
            ),
            // ...add more fields as needed...
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                // Handle save action
              },
            ),
          ],
        ),
      ),
    );
  }
}
