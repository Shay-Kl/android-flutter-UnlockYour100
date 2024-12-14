import 'package:flutter/material.dart';
import 'package:project/content/question.dart';
import '../gpt_service.dart';

const minAnswerCount = 2;
const maxAnswerCount = 6;
final answerCounts = List.generate(
    maxAnswerCount - minAnswerCount + 1, (i) => i + minAnswerCount);

class QuestionEditorContent extends StatefulWidget {
  const QuestionEditorContent({super.key});

  @override
  State<QuestionEditorContent> createState() => _QuestionEditorContentState();
}

class _QuestionEditorContentState extends State<QuestionEditorContent> {
  final FocusNode _questionFocus = FocusNode();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers =
      List.generate(maxAnswerCount, (_) => TextEditingController());

  int _selectedAnswerCount = 4;
  bool loading = false;
  bool questionFilled = false;
  bool answersFilled = false;

  @override
  void initState() {
    super.initState();
    _questionFocus.requestFocus();
    _questionController.addListener(_updateButtonStates);
    for (var controller in _answerControllers) {
      controller.addListener(_updateButtonStates);
    }
  }

  @override
  void dispose() {
    _questionFocus.dispose();
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateButtonStates() {
    setState(() {
      questionFilled = _questionController.text.isNotEmpty;
      for (int i = 0; i < _selectedAnswerCount; i++) {
        if (_answerControllers[i].text.isEmpty) {
          answersFilled = false;
          return;
        }
      }
      answersFilled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: _buildFormFields(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: FilledButton(
          onPressed:
              (questionFilled && answersFilled) ? _handleSavePress : null,
          child: const Text('Save'),
        ),
      ),
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
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child:Text(
          'Answers',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: questionFilled ? null : Colors.grey,
          ),
        ),),
        SegmentedButton<int>(
          segments: answerCounts.map((count) {
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
      ]),
      const Divider(height: 50),
      ...List.generate(_selectedAnswerCount, (index) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              enabled: questionFilled,
              controller: _answerControllers[index],
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      _answerControllers[index].clear();
                      _updateButtonStates();
                    },
                    icon: const Icon(Icons.clear)),
                border: const OutlineInputBorder(),
                labelText: (index == 0) ? 'Correct Answer' : 'Wrong Answer',
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

  void _handleGeneratePress() async {
    setState(() {
      loading = true;
    });
    final answers = await GPTService.generateResponse(_questionController.text);
    _answerControllers[0].text = answers['correct_answer'] ?? '';
    for (int i = 1; i < maxAnswerCount; i++) {
      _answerControllers[i].text = answers['wrong_answers']?[i - 1] ?? '';
    }
    setState(() {
      loading = false;
    });
  }

  void _handleSavePress() {
    final newQuestion = Question(
      _questionController.text,
      _answerControllers[0].text,
      _answerControllers
          .sublist(1, _selectedAnswerCount)
          .map((c) => c.text)
          .toList(),
    );
    Navigator.pop(context, newQuestion);
  }
}
