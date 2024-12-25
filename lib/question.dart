import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;

  List<String> get answers => [correctAnswer, ...wrongAnswers];

  const Question(this.question, this.correctAnswer, this.wrongAnswers);

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'correctAnswer': correctAnswer,
      'wrongAnswers': wrongAnswers,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      map['question'] as String,
      map['correctAnswer'] as String,
      List<String>.from(map['wrongAnswers'] as List<dynamic>),
    );
  }

  factory Question.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question.fromMap(data);
  }
}
