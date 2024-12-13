import 'package:flutter/material.dart';
import 'package:project/content/question.dart';

class QuestionEditorContent extends StatefulWidget {
  const QuestionEditorContent({super.key});

  @override
  State<QuestionEditorContent> createState() => _QuestionEditorContentState();
}

class _QuestionEditorContentState extends State<QuestionEditorContent> {
  int _selectedWrongAnswerCount = 1;
  final List<int> _wrongAnswerCounts = [1, 2, 3, 4];

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _rightAnswerController = TextEditingController();
  final List<TextEditingController> _wrongAnswerControllers =
      List.generate(4, (_) => TextEditingController());

  bool _allFieldsFilled = false;

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
    bool allFilled = _questionController.text.isNotEmpty &&
        _rightAnswerController.text.isNotEmpty;

    for (int i = 0; i < _selectedWrongAnswerCount; i++) {
      if (_wrongAnswerControllers[i].text.isEmpty) {
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
      const SizedBox(height: 10),
      TextField(
        controller: _rightAnswerController,
        decoration: const InputDecoration(
          labelText: 'Answer',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 30),
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
      ),
      const SizedBox(height: 30),
      Column(
        children: List.generate(_selectedWrongAnswerCount, (index) {
          return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: _wrongAnswerControllers[index],
                decoration: const InputDecoration(
                  labelText: 'Wrong Answer',
                  border: OutlineInputBorder(),
                ),
              ));
        }),
      ),
      const SizedBox(height: 20),
    ];
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 55),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: !_allFieldsFilled ? _handleGeneratePress : null,
              child: const Text('Generate'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _allFieldsFilled ? _handleSavePress : null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleGeneratePress() {
    // Handle generate action when fields are incomplete
  }

  void _handleSavePress() {
    final newQuestion = Question(
      _questionController.text,
      _rightAnswerController.text,
      _wrongAnswerControllers
          .sublist(0, _selectedWrongAnswerCount)
          .map((c) => c.text)
          .toList(),
    );

    Navigator.pop(context, newQuestion);
  }
}
