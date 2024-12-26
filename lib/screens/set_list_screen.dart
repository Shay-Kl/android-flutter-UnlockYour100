import 'package:flutter/material.dart';
import 'question_list_screen.dart';

class QuestionSetListContent extends StatelessWidget {
  const QuestionSetListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Set List Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings action
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Edit Set'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuestionListContent()),
            );
          },
        ),
      ),
    );
  }
}
