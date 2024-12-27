import 'dart:ui';
import 'package:flutter/material.dart';

enum SourceType { text, file }

enum Difficulty { trivial, moderate, challenging }

class QuestionGeneratorScreen extends StatefulWidget {
  const QuestionGeneratorScreen({super.key});

  @override
  State<QuestionGeneratorScreen> createState() =>
      _QuestionGeneratorScreenState();
}

class _QuestionGeneratorScreenState extends State<QuestionGeneratorScreen> {
  int _selectedQuestionCount = 10;
  Difficulty _selectedDifficulty = Difficulty.moderate; // Updated type
  SourceType _materialSourceType = SourceType.file;
  SourceType _styleSourceType = SourceType.file;

  final TextEditingController _materialTextController = TextEditingController();
  final TextEditingController _styleTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Questions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number of Questions:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildQuestionCountSelector(),
            const SizedBox(height: 20),
            Text(
              'Difficulty:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildDifficultySelector(),
            const SizedBox(height: 20),
            Text(
              'Question Topic:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildSourceSelector(
              selectedType: _materialSourceType,
              onChanged: (SourceType? value) {
                if (value != null) setState(() => _materialSourceType = value);
              },
              textController: _materialTextController,
              textHint: 'Describe the topic of questions you want to generate',
              fileButtonText: 'Upload Course Material',
            ),
            const SizedBox(height: 20),
            Text(
              'Question Style:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildSourceSelector(
              selectedType: _styleSourceType,
              onChanged: (SourceType? value) {
                if (value != null) setState(() => _styleSourceType = value);
              },
              textController: _styleTextController,
              textHint: "Describe the format of questions you want to generate",
              fileButtonText: 'Upload Course Questions',
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: FilledButton(
          onPressed: _handleGenerate,
          child: const Text('Generate'),
        ),
      ),
    );
  }

  Widget _buildSourceSelector({
    required SourceType selectedType,
    required void Function(SourceType?) onChanged,
    required TextEditingController textController,
    required String textHint,
    required String fileButtonText,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RadioListTile<SourceType>(
                title: const Text('Text'),
                value: SourceType.text,
                groupValue: selectedType,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: RadioListTile<SourceType>(
                title: const Text('File'),
                value: SourceType.file,
                groupValue: selectedType,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        if (selectedType == SourceType.text)
          SizedBox(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: textHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: _handleFileUpload,
            icon: const Icon(Icons.upload_file),
            label: Text(fileButtonText),
          ),
      ],
    );
  }

  Widget _buildQuestionCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _selectedQuestionCount.toString(),
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Slider(
          value: _selectedQuestionCount.toDouble(),
          min: 1,
          max: 20,
          divisions: 19,
          label: _selectedQuestionCount.toString(),
          onChanged: (value) {
            setState(() {
              _selectedQuestionCount = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Center(
      child: SizedBox(
        width: 700,
        child: SegmentedButton<Difficulty>(
          // Updated type
          segments: const [
            ButtonSegment(
              value: Difficulty.trivial,
              label: Text('Trivial', style: TextStyle(fontSize: 12)),
            ),
            ButtonSegment(
              value: Difficulty.moderate,
              label: Text('Moderate', style: TextStyle(fontSize: 12)),
            ),
            ButtonSegment(
              value: Difficulty.challenging,
              label: Text('Challenging', style: TextStyle(fontSize: 12)),
            ),
          ],
          selected: {_selectedDifficulty},
          onSelectionChanged: (newSelection) {
            setState(() {
              _selectedDifficulty = newSelection.first;
            });
          },
        ),
      ),
    );
  }

  void _handleFileUpload() {
    // ...to be implemented...
  }

  void _handleGenerate() {
    // ...call gemini or some service to generate questions...
  }

  @override
  void dispose() {
    _materialTextController.dispose();
    _styleTextController.dispose();
    super.dispose();
  }
}