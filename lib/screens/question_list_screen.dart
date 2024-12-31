import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
//import '../providers/question_provider.dart';
import 'question_editor_screen.dart';
import 'question_generator_screen.dart';
import '../models/question.dart';
import '../providers/set_provider.dart';
// ignore_for_file: use_build_context_synchronously

class QuestionListScreen extends StatefulWidget {
  final String setName;
  const QuestionListScreen(this.setName, {super.key});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  late String setName;
  @override
  Widget build(BuildContext context) {
    final setProvider = Provider.of<SetProvider>(context);
    setName = widget.setName;
    final questions = setProvider.getSetByName(setName).questions;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            title: Text(setName),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final bool? result = await _showDeleteConfirmationDialog(context, setName);
                  if (result == true) {
                    // User confirmed deletion
                    final setProvider = Provider.of<SetProvider>(context, listen: false);
                    setProvider.deleteSet(setName);
                    Navigator.pop(context);
                  } else {
                      // User canceled deletion
                      debugPrint('Deletion canceled');
                  }
                },
              ),
            ],
          ),
        ],
        body: questions.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No questions available. Please create a new one to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              )
            : _buildQuestionList(questions: questions),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.edit),
            label: 'Create manually',
            onTap: () {_handleCreateQuestion(setName);},
          ),
          SpeedDialChild(
            child: const Icon(Icons.auto_awesome),
            label: 'Generate with AI',
            onTap: () {_handleGenerateQuestions(setName);},
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
              onTap: () => _handleEditQuestion(questions, setName, index),
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

  void _handleCreateQuestion(String setName) async {
    final newQuestion = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              QuestionEditorScreen(setName: setName, question: Question.empty())),
    );

    if (newQuestion != null) {
      final setProvider = Provider.of<SetProvider>(context, listen: false);
      setProvider.addQuestionToSet(setName, newQuestion);
    }
  }

  void _handleEditQuestion(List<Question> questions, String setName, int index) async {
    final question = questions[index];
    final editedQuestion = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionEditorScreen(
          setName: setName,
          question: question,
        ),
      ),
    );

    if (editedQuestion != null) {
      editedQuestion.id = question.id;
      final setProvider = Provider.of<SetProvider>(context, listen: false);
      setProvider.updateQuestionInSet(setName, index, editedQuestion);
    }
  }

  void _handleDeleteQuestion(int index) {
    final setProvider = Provider.of<SetProvider>(context, listen: false);
    setProvider.deleteQuestionFromSet(setName, index);
  }

  void _handleGenerateQuestions(String setName) async {
    final newQuestions = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const QuestionGeneratorScreen()));
    if (newQuestions != null) {
      final setProvider = Provider.of<SetProvider>(context, listen: false);
      for (final question in newQuestions) {
        question.setName = setName;
        setProvider.addQuestionToSet(setName, question);
      }
    }
  }
  
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, String setName) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Set'),
        content: const Text('Are you sure you want to delete this set?'),
        actions: [
          TextButton(
            onPressed: () {
              // Cancel deletion
              Navigator.pop(context, false); // Return false for cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Confirm deletion
              Navigator.pop(context, true); // Return true for delete
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}


}


