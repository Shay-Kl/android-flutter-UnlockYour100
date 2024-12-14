import 'package:flutter/material.dart';
import 'package:project/content/question.dart';
import '../gpt_service.dart';

class QuestionEditorContent extends StatefulWidget {
  const QuestionEditorContent({super.key});

  @override
  State<QuestionEditorContent> createState() => _QuestionEditorContentState();
}

class _QuestionEditorContentState extends State<QuestionEditorContent> {
  final _questionFocus = FocusNode();
  bool loading = false;
  int _selectedAnswerCount = 4;
  final List<int> _answerCounts = [2, 3, 4, 5, 6];

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _rightAnswerController = TextEditingController();
  final List<TextEditingController> _wrongAnswerControllers =
      List.generate(5, (_) => TextEditingController());

  bool questionFilled = false;
  bool answersFilled = false;

  @override
  void initState() {
    super.initState();
    _questionFocus.requestFocus();
    _questionController.addListener(_updateButtonStates);
    _rightAnswerController.addListener(_updateButtonStates);
    for (var controller in _wrongAnswerControllers) {
      controller.addListener(_updateButtonStates);
    }
  }

  @override
  void dispose() {
    _questionFocus.dispose();
    super.dispose();
  }

  void _updateButtonStates() {
    setState(() {
      questionFilled = _questionController.text.isNotEmpty;
      for (int i = 0; i < _selectedAnswerCount - 1; i++) {
        if (_wrongAnswerControllers[i].text.isEmpty) {
          answersFilled = false;
          return;
        }
      }
      answersFilled = _rightAnswerController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: _buildFormFields(),
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      TextField(
        focusNode: _questionFocus,
        controller: _questionController,
        decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: () {
                _questionController.clear();
                _updateButtonStates();
              },
              icon: const Icon(Icons.clear)),
          labelText: 'Question',
          border: const OutlineInputBorder(),
        ),
      ),
      const Divider(height: 50),
      Text(
        'Number of Answers:   ',
        style: TextStyle(
          color: questionFilled ? null : Colors.grey,
        ),
      ),
      const SizedBox(height: 10),
      SegmentedButton<int>(
        segments: _answerCounts.map((count) {
          return ButtonSegment<int>(
            value: count,
            label: Text(count.toString()),
          );
        }).toList(),
        selected: {_selectedAnswerCount},
        onSelectionChanged: questionFilled
            ? (newSelection) {
                setState(() {
                  _selectedAnswerCount = newSelection.first;
                });
                _updateButtonStates();
              }
            : null,
        showSelectedIcon: true,
      ),
      const SizedBox(height: 20),
      TextField(
        enabled: questionFilled,
        controller: _rightAnswerController,
        decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: () {
                _rightAnswerController.clear();
                _updateButtonStates();
              },
              icon: const Icon(Icons.clear)),
          labelText: 'Correct Answer',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 10),
      ...List.generate(_selectedAnswerCount - 1, (index) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: TextField(
              enabled: questionFilled,
              controller: _wrongAnswerControllers[index],
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      _wrongAnswerControllers[index].clear();
                      _updateButtonStates();
                    },
                    icon: const Icon(Icons.clear)),
                border: const OutlineInputBorder(),
                labelText: 'Wrong Answer',
              ),
            ));
      }),
      loading
          ? const CircularProgressIndicator()
          : OutlinedButton.icon(
              onPressed: questionFilled ? _handleGeneratePress : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate Answers'),
            ),
    ];
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      child: FilledButton(
        onPressed: (questionFilled && answersFilled) ? _handleSavePress : null,
        child: const Text('Save'),
      ),
    );
  }

  void _handleGeneratePress() async {
    setState(() {
      loading = true;
    });
    final answers = await GPTService.generateResponse(_questionController.text);
    _rightAnswerController.text = answers['correct_answer'] ?? '';
    for (int i = 0; i < 5; i++) {
      _wrongAnswerControllers[i].text = answers['wrong_answers']?[i] ?? '';
    }
    setState(() {
      loading = false;
    });
  }

  void _handleSavePress() {
    final newQuestion = Question(
      _questionController.text,
      _rightAnswerController.text,
      _wrongAnswerControllers
          .sublist(0, _selectedAnswerCount - 1)
          .map((c) => c.text)
          .toList(),
    );

    Navigator.pop(context, newQuestion);
  }
}
