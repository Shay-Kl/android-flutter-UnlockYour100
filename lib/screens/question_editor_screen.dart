import 'package:flutter/material.dart';
import 'dart:math';
import 'package:project/models/question.dart';
import 'package:project/utils/llm_service.dart';

// Define the minimum and maximum number of answers
const minAnswerCount = 2;
const maxAnswerCount = 5;
final answerCounts = List.generate(
    maxAnswerCount - minAnswerCount + 1, (i) => i + minAnswerCount);

class QuestionEditorScreen extends StatefulWidget {
  final Question question;
  final String setName;
  final bool edit;
  const QuestionEditorScreen(
      {super.key,
      required this.setName,
      required this.question,
      required this.edit});

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final FocusNode _questionFocus = FocusNode();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController(); // New controller
  final List<TextEditingController> _answerControllers =
      List.generate(maxAnswerCount, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  late int _selectedAnswerCount;
  bool loading = false;
  bool questionFilled = false;

  @override
  void initState() {
    super.initState();
    Question question = widget.question;
    _selectedAnswerCount = max(question.answers.length, minAnswerCount);

    for (int i = 0; i < question.answers.length; i++) {
      _answerControllers[i].text = question.answers[i];
    }
    _questionController.text = question.question;
    _explanationController.text = question.explanation; // Initialize explanation
    if (!widget.edit) {
      _questionFocus.requestFocus();
    }
    _questionController.addListener(() {
      setState(() {
        questionFilled = _questionController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _questionFocus.dispose();
    _questionController.dispose();
    _explanationController.dispose(); // Dispose explanation controller
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Build Functions
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit ? 'Edit Question' : 'New Question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: _buildFormFields(),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: FilledButton(
          onPressed: () => _handleSavePress(widget.question),
          child: const Text('Save'),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      TextFormField(
        focusNode: _questionFocus,
        controller: _questionController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a question';
          }
          return null;
        },
        decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: () {
                _questionController.clear();
              },
              icon: const Icon(Icons.clear)),
          labelText: 'Question',
          border: const OutlineInputBorder(),
        ),
      ),
      const Divider(height: 30),
      const SizedBox(height: 10),
      Row(children: [
        const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Text(
            'Answers:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: SegmentedButton<int>(
            segments: answerCounts.map((count) {
              return ButtonSegment<int>(
                value: count,
                label: Text(count.toString()),
              );
            }).toList(),
            selected: {_selectedAnswerCount},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedAnswerCount = newSelection.first;
              });
            },
            showSelectedIcon: true,
          ),
        ),
      ]),
      const Divider(height: 30),
      ...List.generate(_selectedAnswerCount, (index) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
              controller: _answerControllers[index],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an answer';
                }
                return null;
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      _answerControllers[index].clear();
                    },
                    icon: const Icon(Icons.clear)),
                border: const OutlineInputBorder(),
                labelText: (index == 0) ? 'Correct Answer' : 'Wrong Answer',
              ),
            ));
      }),
      const Divider(height: 30),
      TextFormField(
        controller: _explanationController, // Explanation field
        validator: (value) {
          //TODO: what to do with all old questions that don't have an explanation?
          //if (value == null || value.isEmpty) {
          if (value == null) {
            return 'Please enter an explanation';
          }
          return null;
        },
        decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: () {
                _explanationController.clear();
              },
              icon: const Icon(Icons.clear)),
          labelText: 'Explanation',
          border: const OutlineInputBorder(),
        ),
      ),
      const Divider(height: 30),
      loading
          ? const CircularProgressIndicator()
          : OutlinedButton.icon(
              onPressed: questionFilled ? _handleGeneratePress : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate Answers'),
            ),
    ];
  }

  // -------------------------------------------------------------------------
  // User Input Handlers
  // -------------------------------------------------------------------------

  void _handleGeneratePress() async {
    setState(() {
      loading = true;
    });
    final Map<String, dynamic> answers =
        await AnswerGenerator.generate(_questionController.text);
    _answerControllers[0].text = answers['correctAnswer'] ?? '';
    for (int i = 1; i < maxAnswerCount; i++) {
      _answerControllers[i].text = answers['wrongAnswers']?[i - 1] ?? '';
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  void _handleSavePress(Question q) {
    debugPrint(q.answeredToday.toString());
    if (_formKey.currentState!.validate()) {
      final newQuestion = Question(
        id: q.id,
        question: _questionController.text,
        correctAnswer: _answerControllers[0].text,
        wrongAnswers: _answerControllers
            .sublist(1, _selectedAnswerCount)
            .map((c) => c.text)
            .toList(),
        explanation: _explanationController.text, // Save explanation
        setName: widget.setName,
        correctAnswers: q.correctAnswers,
        totalAnswers: q.totalAnswers,
        answeredToday: q.answeredToday,
      );
      Navigator.pop(context, newQuestion);
    }
  }
}
