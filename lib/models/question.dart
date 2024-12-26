import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String? id;
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;

  List<String> get answers => [correctAnswer, ...wrongAnswers];

  Question({
    this.id,
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'correctAnswer': correctAnswer,
      'wrongAnswers': wrongAnswers,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String?,
      question: map['question'] as String,
      correctAnswer: map['correctAnswer'] as String,
      wrongAnswers: List<String>.from(map['wrongAnswers'] as List<dynamic>),
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
