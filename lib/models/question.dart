import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String? id;
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final String explanation;
  int correctAnswers;
  int totalAnswers;
  String setName;
  DateTime? lastAnswered;

  List<String> get answers => [correctAnswer, ...wrongAnswers];
  double get successRate =>
      (totalAnswers != 0) ? correctAnswers / totalAnswers : 0;

  Question({
    this.id,
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
    this.explanation = '',
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    required this.setName,
    this.lastAnswered,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Question) return false;
    return id == other.id &&
        question == other.question &&
        correctAnswer == other.correctAnswer &&
        wrongAnswers == other.wrongAnswers &&
        explanation == other.explanation &&
        correctAnswers == other.correctAnswers &&
        totalAnswers == other.totalAnswers &&
        setName == other.setName &&
        lastAnswered == other.lastAnswered;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        question.hashCode ^
        correctAnswer.hashCode ^
        wrongAnswers.hashCode ^
        explanation.hashCode ^
        correctAnswers.hashCode ^
        totalAnswers.hashCode ^
        setName.hashCode ^
        lastAnswered.hashCode; // Include lastAnswered
  }

  Question.empty()
      : this(question: '', correctAnswer: '', wrongAnswers: [], setName: '');

  List<String> getShuffledAnswers() {
    final allAnswers = [correctAnswer, ...wrongAnswers];
    allAnswers.shuffle(Random());
    return allAnswers;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'correctAnswer': correctAnswer,
      'wrongAnswers': wrongAnswers,
      'explanation': explanation,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'setName': setName,
      'lastAnswered': lastAnswered?.toIso8601String(), // Updated field
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String?,
      question: map['question'] as String,
      correctAnswer: map['correctAnswer'] as String,
      wrongAnswers: List<String>.from(map['wrongAnswers'] as List<dynamic>),
      explanation: map['explanation'] as String? ?? '',
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      totalAnswers: map['totalAnswers'] as int? ?? 0,
      setName: map['setName'] as String? ?? '',
      lastAnswered: map['lastAnswered'] != null
          ? DateTime.tryParse(map['lastAnswered'] as String)
          : null,
    );
  }

  factory Question.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      question: data['question'] as String,
      correctAnswer: data['correctAnswer'] as String,
      wrongAnswers: List<String>.from(data['wrongAnswers']),
      explanation: data['explanation'] as String,
      correctAnswers: data['correctAnswers'] as int,
      totalAnswers: data['totalAnswers'] as int,
      lastAnswered: data['lastAnswered'] == null
          ? null
          : (data['lastAnswered'] as Timestamp).toDate(),
      setName: data['setName'] as String,
    );
  }

  bool get isAnsweredToday {
    if (lastAnswered == null) return false;
    final today = DateTime.now();
    return lastAnswered!.year == today.year &&
        lastAnswered!.month == today.month &&
        lastAnswered!.day == today.day;
  }
}
