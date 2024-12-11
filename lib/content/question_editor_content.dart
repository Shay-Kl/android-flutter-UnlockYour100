
import 'package:flutter/material.dart';

class QuestionEditorContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question Editor'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Question Title',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Question Description',
              ),
              maxLines: null,
            ),
            // ...add more fields as needed...
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Save'),
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