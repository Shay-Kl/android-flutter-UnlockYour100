import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
//import '../providers/question_provider.dart';
import 'question_editor_screen.dart';
import 'question_generator_screen.dart';
import '../models/question.dart';
import '../providers/set_provider.dart';
import '../models/colors.dart';
import '../models/set.dart';
import '../providers/theme_provider.dart';
// ignore_for_file: use_build_context_synchronously

class SetEditResult {
  final String name;
  final ColorSchemeKey color;

  SetEditResult(this.name, this.color);
}

class QuestionListScreen extends StatefulWidget {
  final QuestionSet set;
  const QuestionListScreen(this.set, {super.key});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  late String setName;

  @override
  Widget build(BuildContext context) {
    final setProvider = Provider.of<SetProvider>(context);
    final currentSet = widget.set;
    setName = currentSet.setName;
    final questions = currentSet.questions;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            backgroundColor: currentSet.selectedColorKey
                .getColorFromScheme(Theme.of(context).colorScheme),
            title: Text(setName,
                style: TextStyle(
                    color: currentSet.selectedColorKey.getTextColorFromScheme(
                        Theme.of(context).colorScheme))),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final SetEditResult? result = await _showEditSetDialog(
                      context: context,
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
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Dismissible(
          key: ValueKey('${index}_${question.question}'),
          onDismissed: (direction) {
            _handleDeleteQuestion(index);
          },
          background: Container(
            color: Colors.red.shade400,
          ),
          child: Card.outlined(
            margin:
                const EdgeInsets.only(top: 2, bottom: 8, left: 12, right: 12),
            child: Material(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _handleEditQuestion(questions, setName, index),
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(question.question),
                  children: question.answers
                      .map(
                        (answer) => ListTile(
                          dense: true,
                          title: Text(
                            answer,
                            style: TextStyle(
                              color: answer == question.correctAnswer
                                  ? Colors.green
                                  : null,
                            ),
                          ),
                        ),
                      )
                      .toList(),
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

  Future<SetEditResult?> _showEditSetDialog({
    required BuildContext context,
    required String initialName,
    required ColorSchemeKey initialColor,
  }) async {
    final TextEditingController controller =
        TextEditingController(text: initialName);
    ColorSchemeKey selectedColorKey = initialColor;

    return showDialog<SetEditResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Set'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Set name'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    width: double.maxFinite,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: ColorSchemeKey.values.length,
                      itemBuilder: (context, index) {
                        final colorKey = ColorSchemeKey.values[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedColorKey = colorKey;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorKey.getColorFromScheme(
                                  Theme.of(context).colorScheme),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColorKey == colorKey
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                width: selectedColorKey == colorKey ? 3 : 1,
                              ),
                            ),
                            child: selectedColorKey == colorKey
                                ? Icon(
                                    Icons.check,
                                    color: colorKey.getTextColorFromScheme(
                                        Theme.of(context).colorScheme),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty &&
                        (newName != initialName ||
                            selectedColorKey != initialColor)) {
                      Navigator.pop(
                          context, SetEditResult(newName, selectedColorKey));
                    } else {
                      Navigator.pop(context, null);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ); 
          },
        );
      },
    );
  }
}
