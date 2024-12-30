import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../providers/question_provider.dart';
import 'question_editor_screen.dart';
import 'question_generator_screen.dart';
import '../models/question.dart';
//import '../providers/set_provider.dart';
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

  @override
  void initState() {
    super.initState();
    setName = widget.setName;
    final questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    questionsFuture = questionProvider.readQuestionsForUser(setName);
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
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmationDialog(context, setName),
              ),
            ],
          ),
        ],
        body: FutureBuilder(
            future: questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No questions available. Please create a new one to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0), // Optional: Adjust font size for better visibility
                    ),
                  ),
                );
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
      final questionProvider =
          Provider.of<QuestionProvider>(context, listen: false);
      final updatedQuestion =
          await questionProvider.createQuestionForUser(newQuestion, setName);
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
      final questionProvider =
          Provider.of<QuestionProvider>(context, listen: false);
      await questionProvider.updateQuestionForUser(editedQuestion, setName);

      setState(() {
        questions[index] = editedQuestion;
      });
    }
  }

  void _handleDeleteQuestion(int index) async {
    List<Question> questions = await questionsFuture;
    final questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);

    await questionProvider.deleteQuestionForUser(questions[index], setName);

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
    final questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    for (final question in newQuestions) {
      final updatedQuestion =
          await questionProvider.createQuestionForUser(question, setName);
      setState(() {
        questions.add(updatedQuestion);
      });
    }
  }
  
  void _showDeleteConfirmationDialog(BuildContext context, String setName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Set'),
          content: const Text('Are you sure you want to delete this set?'),
          actions: [
            TextButton(
              onPressed: () {
                // Cancel deletion
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Decide how to handle deletion
                // Delete the set
                //final setProvider = Provider.of<SetProvider>(context, listen: false);
                //await setProvider.deleteSet(setName);
                Navigator.pop(context); // Close dialog
                //Navigator.pop(context); // Pop the current screen
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }


}


