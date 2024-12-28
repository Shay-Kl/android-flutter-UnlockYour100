import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:project/models/question.dart';
import '../screens/question_generator_screen.dart';

const modelName = 'gemini-1.5-flash'; // Move to settings singleton eventually

class AnswerGenerator {
  static final systemInstruction = Content.system(
      'You are an exam writer. You will be presented with a question prompt. Output the correct answer to the question and 4 incorrect answers. All answers should be at most 20 words long.');
  static final answersSchema = Schema.object(
    properties: {
      'answers': Schema.object(
        properties: {
          'correctAnswer': Schema.string(),
          'wrongAnswers': Schema.array(items: Schema.string()),
        },
      ),
    },
  );
  static final GenerativeModel model =
      FirebaseVertexAI.instance.generativeModel(
    model: modelName,
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
  static final systemInstruction = Content.system(
      'You are an exam writer. You will be presented with course material and a format for questions. Output a series of multiple choice questions in a format like the one presented to you, on topics found in the course material.');
  static final questionsSchema = Schema.object(
    properties: {
      'questions': Schema.array(
        items: Schema.object(
          properties: {
            'question': Schema.string(),
            'correctAnswer': Schema.string(),
            'wrongAnswers': Schema.array(items: Schema.string()),
          },
        ),
      ),
    },
  );
  static final GenerativeModel model =
      FirebaseVertexAI.instance.generativeModel(
    model: modelName,
    systemInstruction: systemInstruction,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: questionsSchema,
    ),
  );

  static Future<List<Question>> generate(String courseMaterial,
      String questionFormat, int questionCount, Difficulty difficulty) async {
    String prompt =
        'Topic: $courseMaterial\n Format: $questionFormat\n Difficulty: ${difficulty.toString()}\n Question Count: $questionCount';
    final response = await model.generateContent([
      Content.text(prompt),
    ]);
    List<dynamic> questions = jsonDecode(response.text!)['questions'];
    return questions
        .map<Question>((question) => Question.fromMap(question))
        .toList();
  }

  static const Map<Difficulty, String> difficultyMap = {
    Difficulty.trivial: ' Make the questions super basic and straightforward.',
    Difficulty.moderate: '',
    Difficulty.challenging: ' Make the questions as challenging as you can.',
  };

  static Future<List<Question>> generateWithFile(PlatformFile courseMaterial,
      String questionFormat, int questionCount, Difficulty difficulty) async {
    String difficultyPrompt = difficultyMap[difficulty]!;
    final textPrompt = TextPart(
        'Generate $questionCount questions.$difficultyPrompt Make the questions have a format similar to that of $questionFormat. The topic of the questions should all be based on material from the following file:');
    final materialPrompt =
        InlineDataPart('application/pdf', courseMaterial.bytes!);

    final response = await model.generateContent([
      Content.multi([
        textPrompt,
        materialPrompt,
      ]),
    ]);
    List<dynamic> questions = jsonDecode(response.text!)['questions'];
    return questions
        .map<Question>((question) => Question.fromMap(question))
        .toList();
  }
}
