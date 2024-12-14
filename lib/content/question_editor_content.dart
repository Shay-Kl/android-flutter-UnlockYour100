import 'package:flutter/material.dart';
import 'package:project/content/question.dart';
import '../gpt_service.dart';

class QuestionEditorContent extends StatefulWidget {
  const QuestionEditorContent({super.key});

  @override
  State<QuestionEditorContent> createState() => _QuestionEditorContentState();
}

class _QuestionEditorContentState extends State<QuestionEditorContent> {
  bool loading = false;
  int _selectedAnswerCount = 2;
  final List<int> _answerCounts = [2, 3, 4, 5];

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _rightAnswerController = TextEditingController();
  final List<TextEditingController> _wrongAnswerControllers =
      List.generate(4, (_) => TextEditingController());

  bool questionFilled = false;
  bool answersFilled = false;

  @override
  void initState() {
    super.initState();
    _questionController.addListener(_updateButtonStates);
    _rightAnswerController.addListener(_updateButtonStates);
    for (var controller in _wrongAnswerControllers) {
      controller.addListener(_updateButtonStates);
    }
  }

  void _updateButtonStates() {
    setState(() {
      questionFilled = _questionController.text.isNotEmpty;
      for (int i = 0; i < _selectedAnswerCount-1; i++) {
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
        title: const Text('Question Editor'),
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
        controller: _questionController,
        decoration: const InputDecoration(
          labelText: 'Question',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 20),
      SegmentedButton<int>(
        segments: _answerCounts.map((count) {
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
          _updateButtonStates();
        },
        showSelectedIcon: true,
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _rightAnswerController,
        decoration: const InputDecoration(
          labelText: 'Answer',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 10),
      ...List.generate(_selectedAnswerCount-1, (index) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: TextField(
              controller: _wrongAnswerControllers[index],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Wrong Answer',
              ),
            ));
      }),
      loading ? const CircularProgressIndicator() : OutlinedButton(
        onPressed:
            (questionFilled && !answersFilled) ? _handleGeneratePress : null,
        child: const Text('Generate Answers'),
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
    for (int i = 0; i < 4; i++) {
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
          .sublist(0, _selectedAnswerCount-1)
          .map((c) => c.text)
          .toList(),
    );

    Navigator.pop(context, newQuestion);
  }
}
