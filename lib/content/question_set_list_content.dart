
import 'package:flutter/material.dart';
import 'question_list_content.dart';

class QuestionSetListContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question Set List Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Handle settings action
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Edit Set'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuestionListContent()),
            );
          },
        ),
      ),
    );
  }
}