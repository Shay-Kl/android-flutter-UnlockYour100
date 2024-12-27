import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../screens/question_generator_screen.dart';


const modelName = 'gemini-1.5-flash'; // Move to settings singleton eventually

class AnswerGenerator {
  static final systemInstruction = Content.system(
      'You are an exam writer. You will be presented with a question prompt. Output the correct answer to the question and 4 incorrect answers. All answers should be at most 20 words long.');
  static final answersSchema = Schema.object(
    properties: {
      'answers': Schema.object(
        properties: {
          'correct_answer': Schema.string(),
          'wrong_answers': Schema.array(items: Schema.string()),
        },
      ),
    },
  );
  static final GenerativeModel model = FirebaseVertexAI.instance.generativeModel(
    model: modelName,
    systemInstruction: systemInstruction,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: answersSchema,
    ),
  );

  static generate(String question) async {
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
            'correct_answer': Schema.string(),
            'wrong_answers': Schema.array(items: Schema.string()),
          },
        ),
      ),
    },
  );
  static final GenerativeModel model = FirebaseVertexAI.instance.generativeModel(
    model: modelName,
    systemInstruction: systemInstruction,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: questionsSchema,
    ),
  );

  static generate(String courseMaterial, String questionFormat, int questionCount, Difficulty difficulty) async {
    final response = await model.generateContent(
      [
        Content.text('Topic: $courseMaterial\n Format: $questionFormat\n Difficulty: ${difficulty.toString()}\n Question Count: $questionCount'), 
      ],
    );
    print(response.text);
    return jsonDecode(response.text!)['questions'];
  }
}