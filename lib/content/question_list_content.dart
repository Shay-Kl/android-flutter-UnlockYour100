import 'package:flutter/material.dart';
import 'question_editor_content.dart';

class QuestionListContent extends StatelessWidget {
  const QuestionListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question List'),
      ),
      body: ListView(
        children: const [
          Card(
            child: ListTile(
              title: Text('Question 1'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuestionEditorContent()),
          );
        },
      ),
    );
  }
}
