import 'package:flutter/material.dart';
import 'package:project/widgets/set_creator_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'question_editor_screen.dart';
import 'question_generator_screen.dart';
import '../models/question.dart';
import '../providers/set_provider.dart';
import '../models/colors.dart';
import '../models/set.dart';
import '../widgets/question_card.dart';

class QuestionListScreen extends StatefulWidget {
  final QuestionSet set;
  const QuestionListScreen(this.set, {super.key});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  late String setName;

  // -------------------------------------------------------------------------
  // Build Functions
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final setProvider = Provider.of<SetProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final currentSet = widget.set;
    setName = currentSet.setName;
    final questions = currentSet.questions;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            backgroundColor: currentSet.selectedColorKey
                .getColorFromScheme(Theme.of(context).colorScheme),
            title: Text(
              setName,
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: QuestionSearchDelegate(
                      questions: questions,
                      onEditQuestion: _handleEditQuestion,
                      buildQuestionList: (filteredQuestions) =>
                          _buildQuestionList(questions: filteredQuestions),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await showNewSetDialog(
                      context, setProvider, false,
                      initialName: setName,
                      initialColor: currentSet.selectedColorKey);
                  if (result != null) {
                    setProvider.updateSetColorAndName(
                        setName, result.color, result.name);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final bool? result =
                      await _showDeleteConfirmationDialog(context, setName);
                  if (result == true) {
                    // User confirmed deletion
                    final setProvider =
                        Provider.of<SetProvider>(context, listen: false);
                    setProvider.deleteSet(setName);
                    Navigator.pop(context);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.edit),
            label: 'Create manually',
            onTap: () {
              _handleCreateQuestion(setName);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.auto_awesome),
            label: 'Generate with AI',
            onTap: () {
              _handleGenerateQuestions(setName);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList({required List<Question> questions}) {
    // Sort questions alphabetically by the question text
    final sortedQuestions = List<Question>.from(questions)
      ..sort((a, b) => a.question.compareTo(b.question));
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 20),
      itemCount: sortedQuestions.length,
      itemBuilder: (context, index) {
        final question = sortedQuestions[index];
        return Dismissible(
          key: ValueKey('${index}_${question.question}'),
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
            _handleDeleteQuestion(sortedQuestions[index].id);
          },
          background: Container(
            color: Colors.red.shade400,
          ),
          child: QuestionCard(
            question: question,
            onTap: () => _handleEditQuestion(sortedQuestions, setName, index),
            margin:
                const EdgeInsets.only(top: 2, bottom: 8, left: 12, right: 12),
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
          builder: (context) => QuestionEditorScreen(
              setName: setName, question: Question.empty(), edit: false)),
    );

    if (newQuestion != null) {
      final setProvider = Provider.of<SetProvider>(context, listen: false);
      setProvider.addQuestionToSet(setName, newQuestion);
    }
  }

  void _handleEditQuestion(
      List<Question> questions, String setName, int index) async {
    final question = questions[index];
    final editedQuestion = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionEditorScreen(
            setName: setName, question: question, edit: true),
      ),
    );

    if (editedQuestion != null) {
      editedQuestion.id = question.id;
      final setProvider = Provider.of<SetProvider>(context, listen: false);
      setProvider.updateQuestionInSet(setName, editedQuestion);
    }
  }

  void _handleDeleteQuestion(String? id) async {
    final setProvider = Provider.of<SetProvider>(context, listen: false);
    setProvider.deleteQuestionFromSet(setName, id);
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
        setState(() {
          setProvider.addQuestionToSet(setName, question);
        });
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(
      BuildContext context, String setName) {
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

class QuestionSearchDelegate extends SearchDelegate {
  final List<Question> questions;
  final void Function(List<Question>, String, int) onEditQuestion;
  final Widget Function(List<Question>) buildQuestionList; // New field

  QuestionSearchDelegate({
    required this.questions,
    required this.onEditQuestion,
    required this.buildQuestionList, // New parameter
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search bar
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filter questions based on whether the query matches either the question or the answer
    final filteredQuestions = questions
        .where((question) =>
            question.question
                .toLowerCase()
                .contains(query.toLowerCase()) || // Match in question
            question.answers.any((answer) => answer
                .toLowerCase()
                .contains(query.toLowerCase()))) // Match in any answer
        .toList();

    if (filteredQuestions.isEmpty) {
      return const Center(
        child: Text(
          'No matching questions or answers found.',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    }
    return buildQuestionList(filteredQuestions);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredQuestions = questions
        .where((question) =>
            question.question
                .toLowerCase()
                .contains(query.toLowerCase()) || // Match in question
            question.answers.any((answer) => answer
                .toLowerCase()
                .contains(query.toLowerCase()))) // Match in any answer
        .toList();

    if (filteredQuestions.isEmpty) {
      return const Center(
        child: Text(
          'No matching questions or answers found.',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    }
    return buildQuestionList(filteredQuestions);
  }
}
