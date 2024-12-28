import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../providers/question_provider.dart';
import 'question_editor_screen.dart';
import 'question_generator_screen.dart';
import '../models/question.dart';
// ignore_for_file: use_build_context_synchronously

class QuestionListScreen extends StatefulWidget {
  final String setName;
  const QuestionListScreen(this.setName, {super.key});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  late Future<List<Question>> questionsFuture;
  late String setName;
  late final QuestionProvider _questionProvider;

  @override
  void initState() {
    super.initState();
    setName = widget.setName;
    _questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    questionsFuture = _questionProvider.readQuestionsForUser(setName);
  }

  // -------------------------------------------------------------------------
  // Build Functions
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            title: Text(setName),
          ),
        ],
        body: FutureBuilder(
            future: questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return _buildQuestionList(
                  questions: snapshot.data as List<Question>,
                );
              }
            }),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.edit),
            label: 'Create manually',
            onTap: _handleCreateQuestion,
          ),
          SpeedDialChild(
            child: const Icon(Icons.auto_awesome),
            label: 'Generate with AI',
            onTap: _handleGenerateQuestions,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList({required List<Question> questions}) {
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: ValueKey('${index}_${questions[index].question}'),
          onDismissed: (direction) {
            _handleDeleteQuestion(index);
          },
          background: Container(
            color: Colors.red.shade400,
          ),
          child: Card.outlined(
            margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _handleEditQuestion(index),
              child: ListTile(
                title: Text(questions[index].question),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: questions[index]
                      .answers
                      .asMap()
                      .entries
                      .map<Widget>((entry) {
                    final answer = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text('- $answer'),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // User Input Handlers
  // -------------------------------------------------------------------------

  void _handleCreateQuestion() async {
    final newQuestion = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              QuestionEditorScreen(question: Question.empty())),
    );

    if (newQuestion != null) {
      final updatedQuestion =
          await _questionProvider.createQuestionForUser(newQuestion, setName);
      final questions = await questionsFuture;
      setState(() {
        questions.add(updatedQuestion);
      });
    }
  }

  void _handleEditQuestion(int index) async {
    final List<Question> questions = await questionsFuture;
    final question = questions[index];
    final editedQuestion = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionEditorScreen(
          question: question,
        ),
      ),
    );

    if (editedQuestion != null) {
      editedQuestion.id = question.id;
      await _questionProvider.updateQuestionForUser(editedQuestion, setName);

      setState(() {
        questions[index] = editedQuestion;
      });
    }
  }

  void _handleDeleteQuestion(int index) async {
    List<Question> questions = await questionsFuture;
    await _questionProvider.deleteQuestionForUser(questions[index], setName);

    setState(() {
      questions.removeAt(index);
    });
  }

  void _handleGenerateQuestions() async {
    final newQuestions = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const QuestionGeneratorScreen()));
    if (newQuestions == null) return;
    final questions = await questionsFuture;
    for (final question in newQuestions) {
      final updatedQuestion =
          await _questionProvider.createQuestionForUser(question, setName);
      setState(() {
        questions.add(updatedQuestion);
      });
    }
  }
}
