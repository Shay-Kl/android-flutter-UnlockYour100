import 'package:flutter/material.dart';
import '../models/question.dart';

class QuizScreen extends StatefulWidget {

  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<String>? shuffledAnswers;
  String? selectedAnswer;
  Question question = Question(
    question: 'What is the capital of France?',
    correctAnswer: 'Paris',
    wrongAnswers: ['London', 'Berlin', 'Madrid'],
  );

  @override
  void initState() {
    super.initState();
    // Shuffle answers only once when the widget is initialized
    shuffledAnswers = question.getShuffledAnswers();
  }

  @override
  Widget build(BuildContext context) {
    if (shuffledAnswers == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Question")),
        body: const Center(child: CircularProgressIndicator()), // Show a loader while initializing
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Question"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First card with the question
            Card(
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question.question,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16), // Spacer

            // Other cards with answers
            ...shuffledAnswers!.map((answer) {
              final isCorrect = answer == question.correctAnswer;
              final isSelected = selectedAnswer == answer;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAnswer = answer;
                  });
                },
                child: Card(
                  color: isSelected
                      ? (isCorrect ? Colors.green : Colors.red)
                      : (isCorrect && selectedAnswer != null
                          ? Colors.green
                          : Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      answer,
                      style: TextStyle(
                        fontSize: 18,
                        color: (isSelected || isCorrect && selectedAnswer != null) ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}