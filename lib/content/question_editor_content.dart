import 'package:flutter/material.dart';
import 'package:project/content/question.dart';
import '../gpt_service.dart';

const minAnswerCount = 2;
const maxAnswerCount = 5;
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
  final _formKey = GlobalKey<FormState>();
  int _selectedAnswerCount = 4;
  bool loading = false;
  bool questionFilled = false;

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
          onPressed: _handleSavePress,
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
                _updateButtonStates();
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
            'Answers',
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
              _updateButtonStates();
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
                      _updateButtonStates();
                    },
                    icon: const Icon(Icons.clear)),
                border: const OutlineInputBorder(),
                labelText: (index == 0) ? 'Correct Answer' : 'Wrong Answer',
              ),
            ));
      }),
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
    if (_formKey.currentState!.validate()) {
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
}
