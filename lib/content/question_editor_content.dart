import 'package:flutter/material.dart';
import 'package:project/content/question.dart';

class QuestionEditorContent extends StatefulWidget {
  const QuestionEditorContent({super.key});

  @override
  State<QuestionEditorContent> createState() => _QuestionEditorContentState();
}

class _QuestionEditorContentState extends State<QuestionEditorContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  int _selectedWrongAnswerCount = 1;
  final List<int> _wrongAnswerCounts = [1, 2, 3, 4];
  final List<TextEditingController> _answerControllers =
      List.generate(5, (_) => TextEditingController());
  bool _allFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _questionController.addListener(_updateButtonStates);
    for (var controller in _answerControllers) {
      controller.addListener(_updateButtonStates);
    }
  }

  void _updateButtonStates() {
    bool allFilled = _questionController.text.isNotEmpty &&
        _answerControllers[0].text.isNotEmpty;

    for (int i = 1; i <= _selectedWrongAnswerCount; i++) {
      if (_answerControllers[i].text.isEmpty) {
        allFilled = false;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _allFieldsFilled = allFilled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Editor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _answerControllers[0],
                decoration: InputDecoration(
                  labelText: 'Answer',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade200),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an answer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const SizedBox(width: 10),
              SegmentedButton<int>(
                segments: _wrongAnswerCounts.map((count) {
                  return ButtonSegment<int>(
                    value: count,
                    label: Text(count.toString()),
                  );
                }).toList(),
                selected: {_selectedWrongAnswerCount},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedWrongAnswerCount = newSelection.first;
                  });
                  _updateButtonStates();
                },
                showSelectedIcon: true,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: List.generate(_selectedWrongAnswerCount, (index) {
                  return TextFormField(
                    controller: _answerControllers[index + 1],
                    decoration: InputDecoration(
                      labelText: 'Wrong Answer',
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red.shade200),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an answer';
                      }
                      return null;
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: !_allFieldsFilled
                    ? () {
                        // Handle generate action when fields are incomplete
                      }
                    : null,
                child: const Text('Generate'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _allFieldsFilled
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          final newQuestion = Question(
                            _questionController.text,
                            _answerControllers[0].text,
                            _answerControllers
                                .sublist(1, _selectedWrongAnswerCount + 1)
                                .map((c) => c.text)
                                .toList(),
                          );
                          
                          Navigator.pop(context, newQuestion);
                        }
                      }
                    : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
