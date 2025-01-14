import 'dart:convert';
//import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:project/models/question.dart';
import 'package:project/utils/settings_manager.dart';
import '../screens/question_generator_screen.dart';

class AnswerGenerator {
  static final systemInstruction = Content.system(
      """You are an exam writer. You will be presented with a question prompt. 
      Output the correct answer to the question and 4 incorrect answers. 
      All answers should be at most 20 words long.
      Do not explain the rational for the answer within the answer itself. Keep the answers concise. Do this for both correct and incorrect answers.
      In the case of the correct answer, do not include any information that would make it stand out from the incorrect answers.
      In the explanation field, provide a brief explanation of why the correct answer is correct. Keep it under 50 words.
      """);
  static final answersSchema = Schema.object(
    properties: {
      'answers': Schema.object(
        properties: {
          'correctAnswer': Schema.string(),
          'wrongAnswers': Schema.array(items: Schema.string()),
          'explanation': Schema.string(),
        },
      ),
    },
  );
  static final GenerativeModel model =
      FirebaseVertexAI.instance.generativeModel(
    model: SettingsManager.instance.model,
    systemInstruction: systemInstruction,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: answersSchema,
    ),
  );

  static Future<Map<String, dynamic>> generate(String question) async {
    final response = await model.generateContent([Content.text(question)]);
    return jsonDecode(response.text!)['answers'];
  }
}

class QuestionGenerator {
  static final systemInstruction = Content.system("""You are an exam writer. 
      You will be presented with course material and a format for questions. 
      Output a series of multiple choice questions in a format like the one presented to you, 
      on topics found in the course material. 
      Try to make the length of correct answers similar to that of incorrect answers so that there wont be any obvious giveaways.
      Do not write a more detailed explanation for the correct answer than for the incorrect answers.
      Do not explain the rational for the answer within the answer itself. Keep the answers concise. Do this for both correct and incorrect answers.
      In the case of the correct answer, do not include any information that would make it stand out from the incorrect answers.
      In the explanation field, provide a brief explanation of why the correct answer is correct. Explain what sets it apart from the incorrect answers.

      Don't repeat the same question twice.
      Don't use the same answer twice in the same question.
      Don't repeat information found in the question in the answers.
      Always output questions and answers in English. No matter what language the input is in.
      """);
  static final questionsSchema = Schema.object(
    properties: {
      'questions': Schema.array(
        items: Schema.object(
          properties: {
            'question': Schema.string(),
            'correctAnswer': Schema.string(),
            'wrongAnswers': Schema.array(items: Schema.string()),
            'explanation': Schema.string(),
          },
        ),
      ),
    },
  );
  static final GenerativeModel model =
      FirebaseVertexAI.instance.generativeModel(
    model: SettingsManager.instance.model,
    systemInstruction: systemInstruction,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: questionsSchema,
    ),
  );

  static const Map<Difficulty, String> difficultyMap = {
    Difficulty.trivial: ' Make the questions super basic and straightforward.',
    Difficulty.moderate: ' ',
    Difficulty.hard: ' Make the questions as challenging as you can.',
  };

  static Future<List<Question>> generate(LLMInput material, LLMInput format,
      int questionCount, Difficulty difficulty, int answerCount) async {
    final formatPrompt = format is TextInput
        ? TextPart(format.text)
        : InlineDataPart(
            (format as FileInput).getMimeType(), format.file.bytes!);

    final materialPrompt = material is TextInput
        ? TextPart(material.text)
        : InlineDataPart(
            (material as FileInput).getMimeType(), material.file.bytes!);

    final content = Content.multi([
      TextPart(
          'Generate exactly $questionCount questions with exactly $answerCount answers each (1 correct, ${answerCount - 1} incorrect).'),
      TextPart(difficultyMap[difficulty]!),
      TextPart('The questions should have a format similar to that of:\n'),
      formatPrompt,
      TextPart(
          'The topic of the questions should all be based on material from the following text:\n'),
      materialPrompt,
    ]);
    final response = await model.generateContent([content]);

    final questions = jsonDecode(response.text!)['questions'];
    return questions
        .map<Question>((question) => Question.fromMap(question))
        .toList();
  }
}

abstract class LLMInput {}

class TextInput extends LLMInput {
  final String text;
  TextInput(this.text);
}

class FileInput extends LLMInput {
  final PlatformFile file;
  FileInput(this.file);
  String getMimeType() {
    final extension = file.name.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
