import 'package:flutter/material.dart';
import 'package:project/models/set.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/question_provider.dart';
import 'question_editor_screen.dart';
import '../models/question.dart';

class QuestionListContent extends StatefulWidget {
  final QuestionSet s;
  const QuestionListContent(this.s, {super.key});

  @override
  State<QuestionListContent> createState() => _QuestionListContentState();
}

class _QuestionListContentState extends State<QuestionListContent> {
  List<Question> questions = [];
  late String setName;

  @override
  void initState() {
    setName = widget.s.setName;
    super.initState();
    _fetchQuestionsFromFirestore();
  }

  Future<void> _fetchQuestionsFromFirestore() async {
    final userEmail =
        Provider.of<AuthProvider>(context, listen: false).userEmail;
    final provider = Provider.of<QuestionProvider>(context, listen: false);
    final fetchedQuestions =
        await provider.readQuestionsForUser(userEmail!, setName);
    setState(() {
      questions = fetchedQuestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            title: Text(setName),
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
                      content: const Text(
                          'Are you sure you want to delete this question?'),
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
                deleteQuestion(index);
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
                margin:
                    const EdgeInsets.symmetric(vertical: 7.5, horizontal: 20),
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
      MaterialPageRoute(builder: (context) => QuestionEditorContent()),
    );

    if (newQuestion != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      var username = '${authProvider.userEmail}';
      final updatedQuestion =
          await Provider.of<QuestionProvider>(context, listen: false)
              .createQuestionForUser(newQuestion, username, setName);

      setState(() {
        print(updatedQuestion.id);
        questions.add(updatedQuestion);
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userEmail = authProvider.userEmail!;
      final questionProvider =
          Provider.of<QuestionProvider>(context, listen: false);
      editedQuestion.id = questions[index].id;
      await questionProvider.updateQuestionForUser(
          editedQuestion, userEmail, setName);

      setState(() {
        questions[index] = editedQuestion;
      });
    }
  }

  Future<void> deleteQuestion(int index) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.userEmail!;
    final questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    final questionToDelete = questions[index];

    await questionProvider.deleteQuestionForUser(
        questionToDelete, userEmail, setName);

    setState(() {
      questions.removeAt(index);
    });
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
