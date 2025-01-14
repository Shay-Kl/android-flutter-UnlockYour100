import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project/screens/question_generation_confirmation_screen.dart';
import '../utils/llm_service.dart';

const int maxFileSize = 10 * 1024 * 1024;

enum SourceType { text, file }
enum Difficulty { trivial, moderate, hard }

// Add these constants
const minAnswerCount = 2;
const maxAnswerCount = 5;
final answerCounts = List.generate(
    maxAnswerCount - minAnswerCount + 1, (i) => i + minAnswerCount);

class QuestionGeneratorScreen extends StatefulWidget {
  const QuestionGeneratorScreen({super.key});

  @override
  State<QuestionGeneratorScreen> createState() =>
      _QuestionGeneratorScreenState();
}

class _QuestionGeneratorScreenState extends State<QuestionGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  int _selectedQuestionCount = 5;
  int _selectedAnswerCount = 4;  // Add this line
  Difficulty _selectedDifficulty = Difficulty.moderate; // Updated type
  SourceType _materialSourceType = SourceType.file;
  SourceType _styleSourceType = SourceType.file;

  final TextEditingController _materialTextController = TextEditingController();
  final TextEditingController _styleTextController = TextEditingController();

  PlatformFile? _materialFile;
  PlatformFile? _styleFile;
  bool loading = false;
  bool _isUploading = false;
  String? _uploadingButtonType;

  // -------------------------------------------------------------------------
  // Build Functions
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Questions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Questions:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildQuestionCountSelector(),
              const SizedBox(height: 10),
              Text(
                'Answers per Question:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildAnswerCountSelector(),
              const SizedBox(height: 15),
              Text(
                'Difficulty:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildDifficultySelector(),
              const SizedBox(height: 15),
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
                selectedFile: _materialFile,
              ),
              const SizedBox(height: 15),
              Text(
                'Question Style (Optional):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildSourceSelector(
                  selectedType: _styleSourceType,
                  onChanged: (SourceType? value) {
                    if (value != null) setState(() => _styleSourceType = value);
                  },
                  textController: _styleTextController,
                  textHint:
                      "Describe the format of questions you want to generate",
                  fileButtonText: 'Upload Example Questions',
                  selectedFile: _styleFile),
                  
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: (loading)
            ? const LinearProgressIndicator()
            : FilledButton(
                onPressed: _isUploading ? null : _handleGenerate,
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
    PlatformFile? selectedFile,
  }) {
    final bool isMaterial = fileButtonText.contains('Material');
    final bool isCurrentlyUploading = _isUploading &&
        _uploadingButtonType == (isMaterial ? 'material' : 'style');
    final bool otherIsUploading = _isUploading &&
        _uploadingButtonType != (isMaterial ? 'material' : 'style');

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
          TextFormField(
            controller: textController,
            decoration: InputDecoration(
              hintText: textHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (_materialSourceType == SourceType.text &&
                  textController == _materialTextController &&
                  (value == null || value.isEmpty)) {
                return 'Please enter a course material';
              }
              // Remove style text validation - making it optional
              return null;
            },
          )
        else
          FormField<PlatformFile?>(
            validator: (value) {
              if (_materialSourceType == SourceType.file &&
                  fileButtonText.contains('Material') &&
                  selectedFile == null) {
                return 'Please upload a course material file (PDF or image)';
              }
              return null;
            },
            builder: (field) {
              return Column(
                children: [
                  if (isCurrentlyUploading)
                    const SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: otherIsUploading
                          ? null
                          : () => _handleFileUpload(
                                isMaterial: isMaterial,
                              ),
                      icon: const Icon(Icons.upload_file),
                      label: Text(fileButtonText),
                    ),
                  if (selectedFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        'Selected: ${selectedFile.name}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        field.errorText ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              );
            },
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

  Widget _buildAnswerCountSelector() {
    return Center(
      child: SizedBox(
        width: 700,
        child: SegmentedButton<int>(
          segments: answerCounts.map((count) {
            return ButtonSegment<int>(
              value: count,
              label: Text(count.toString(), style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          selected: {_selectedAnswerCount},
          onSelectionChanged: (newSelection) {
            setState(() {
              _selectedAnswerCount = newSelection.first;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Center(
        child: SizedBox(
      width: 700,
      child: SegmentedButton<Difficulty>(
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
            value: Difficulty.hard,
            label: Text('Hard', style: TextStyle(fontSize: 12)),
          ),
        ],
        selected: {_selectedDifficulty},
        onSelectionChanged: (newSelection) {
          setState(() {
            _selectedDifficulty = newSelection.first;
          });
        },
      ),
    ));
  }

  // -------------------------------------------------------------------------
  // User Input Handlers
  // -------------------------------------------------------------------------

  Future<void> _handleFileUpload({required bool isMaterial}) async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadingButtonType = isMaterial ? 'material' : 'style';
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && mounted) {
        final filePath = result.files.single.path;
        if (filePath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Could not get file path'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        final file = File(filePath);
        final size = await file.length();

        if (size > maxFileSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File too large. Maximum size is 10 MB.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Only now load the file data
        final fileBytes = await file.readAsBytes();
        final platformFile = PlatformFile(
          path: filePath,
          name: result.files.single.name,
          size: size,
          bytes: fileBytes,
        );

        setState(() {
          if (isMaterial) {
            _materialFile = platformFile;
          } else {
            _styleFile = platformFile;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadingButtonType = null;
        });
      }
    }
  }

  void _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    LLMInput materialInput = _materialSourceType == SourceType.file
        ? FileInput(_materialFile!)
        : TextInput(_materialTextController.text);

    // Make style input optional by using null when no style is provided
    LLMInput styleInput = TextInput(' ');
    if (_styleSourceType == SourceType.file && _styleFile != null) {
      styleInput = FileInput(_styleFile!);
    } else if (_styleSourceType == SourceType.text &&
        _styleTextController.text.isNotEmpty) {
      styleInput = TextInput(_styleTextController.text);
    }

    try {
      final questions = await QuestionGenerator.generate(
        materialInput,
        styleInput,
        _selectedQuestionCount,
        _selectedDifficulty,
        _selectedAnswerCount,
      );
      if (!mounted) return;

      final selectedQuestions = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionGenerationConfirmationScreen(
            questions: questions,
          ),
        ),
      );

      if (selectedQuestions != null) {
        if (!mounted) return;
        Navigator.pop(context, selectedQuestions);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating questions: $e')),
      );
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    _materialTextController.dispose();
    _styleTextController.dispose();
    super.dispose();
  }
}
