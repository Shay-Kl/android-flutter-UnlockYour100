
import 'package:flutter/material.dart';
import 'question_editor_content.dart';

class QuestionListContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question List'),
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: Text('Question 1'),
            ),
          ),
          // ...add more cards as needed...
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
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