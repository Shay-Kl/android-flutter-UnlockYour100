import 'package:flutter/material.dart';
import 'question_editor_content.dart';
import 'question.dart';

const ph1 = Question('What is the capital of Israel?', 'Jerusalem',
    ['Yotvata', 'Haifa', 'Berlin']);
const ph2 = Question('Where did the fellowship of the ring head?', 'Mordor',
    ['Valinor', 'Rhun', 'Numenor']);

class QuestionListContent extends StatefulWidget {
  const QuestionListContent({super.key});

  @override
  State<QuestionListContent> createState() => _QuestionListContentState();
}

class _QuestionListContentState extends State<QuestionListContent> {
  var questions = [ph1, ph2];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geography 101'),
      ),
      body: ListView(
        children: questions.map((q) {
          return QuestionCard(q);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newQuestion = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const QuestionEditorContent()),
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

class QuestionCard extends StatelessWidget {
  final Question q;
  const QuestionCard(this.q, {super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 20),
      child: ListTile(
        title: Text(q.question),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: q.answers.asMap().entries.map<Widget>((entry) {
            final answer = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text('- $answer'),
            );
          }).toList(),
        ),
      ),
    );
  }
}
