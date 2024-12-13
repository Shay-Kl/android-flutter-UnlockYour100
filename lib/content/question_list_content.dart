import 'package:flutter/material.dart';
import 'question_editor_content.dart';

class QuestionListContent extends StatefulWidget {
  const QuestionListContent({super.key});

  @override
  State<QuestionListContent> createState() => _QuestionListContentState();
}

class _QuestionListContentState extends State<QuestionListContent> {
  List<Map<String, dynamic>> questions = [
    {
      'question': 'What is the capital of Israel?',
      'answers': ['Yotvata', 'Jerusalem', 'Haifa', 'Berlin']
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set 1'),
      ),
      body: ListView(
        children: questions.map((question) {
          return Card(
            child: ListTile(
              title: Text(question['question']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: question['answers'].asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: index == 0 
                          ? Colors.green.shade50 
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('- $answer'),
                  );
                }).toList(),
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newQuestion = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuestionEditorContent()),
          );
          if (newQuestion != null) {
            setState(() {
              questions.add(newQuestion);
            });
          }
        },
      ),
    );
  }
}
