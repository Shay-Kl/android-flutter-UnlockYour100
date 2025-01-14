import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String? id;
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final String explanation; // Added explanation field
  int correctAnswers;
  int totalAnswers;
  String setName;

  List<String> get answers => [correctAnswer, ...wrongAnswers];

  Question({
    this.id,
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
    this.explanation = '', // Initialize explanation
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    required this.setName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Question) return false;
    return id == other.id &&
        question == other.question &&
        correctAnswer == other.correctAnswer &&
        wrongAnswers == other.wrongAnswers &&
        explanation == other.explanation && // Compare explanation
        correctAnswers == other.correctAnswers &&
        totalAnswers == other.totalAnswers &&
        setName == other.setName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        question.hashCode ^
        correctAnswer.hashCode ^
        wrongAnswers.hashCode ^
        explanation.hashCode ^ // Include explanation
        correctAnswers.hashCode ^
        totalAnswers.hashCode ^
        setName.hashCode;
  }

  Question.empty() : this(question: '', correctAnswer: '', wrongAnswers: [], setName: '');
  
  List<String> getShuffledAnswers() {
    final allAnswers = [correctAnswer, ...wrongAnswers];
    allAnswers.shuffle(Random()); // Shuffle the list
    return allAnswers;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'correctAnswer': correctAnswer,
      'wrongAnswers': wrongAnswers,
      'explanation': explanation, // Add explanation to map
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'setName': setName,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String?,
      question: map['question'] as String,
      correctAnswer: map['correctAnswer'] as String,
      wrongAnswers: List<String>.from(map['wrongAnswers'] as List<dynamic>),
      explanation: map['explanation'] as String? ?? '', // Initialize explanation
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      totalAnswers: map['totalAnswers'] as int? ?? 0,
      setName: map['setName'] as String? ?? '',
    );
  }

  factory Question.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question.fromMap({
      'id': doc.id,
      ...data,
    });
  }
}
