
import 'package:flutter/material.dart';
import 'question_list_screen.dart';

class SetListContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set List Screen'),
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
              MaterialPageRoute(builder: (context) => QuestionListScreen()),
            );
          },
        ),
      ),
    );
  }
}