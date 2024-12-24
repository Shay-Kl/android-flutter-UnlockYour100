import 'package:flutter/material.dart';
import 'question_editor_content.dart';
import '../question.dart';

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
  List<Question> questions = [ph1, ph2, ph1, ph2, ph1, ph2, ph1, ph2, ph1, ph2];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          const SliverAppBar.large(
            title: Text('Geography 101'),
          ),
        ],
        body: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey('${index}_${questions[index].question}'),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Question'),
                      content: const Text('Are you sure you want to delete this question?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                setState(() {
                  questions.removeAt(index);
                });
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card.outlined(
                margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => editQuestion(index),
                  child: QuestionCardContents(q: questions[index]),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createQuestion,
        child: const Icon(Icons.add),
      ),
    );
  }

  void createQuestion() async {
    final newQuestion = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuestionEditorContent()),
    );
    if (newQuestion != null) {
      setState(() {
        questions.add(newQuestion);
      });
    }
  }

  void editQuestion(int index) async {
    final editedQuestion = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionEditorContent.edit(
          question: questions[index],
        ),
      ),
    );
    if (editedQuestion != null) {
      setState(() {
        questions[index] = editedQuestion;
      });
    }
  }
}

class QuestionCardContents extends StatelessWidget {
  final Question q;
  const QuestionCardContents({super.key, required this.q});

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}
