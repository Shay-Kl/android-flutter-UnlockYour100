import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

class QuestionSet {
  final String setName;
  bool isActive;
  final List<Question> questions;

  QuestionSet({
    required this.setName,
    this.isActive = true,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'setName': setName,
      'isActive': isActive,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  static QuestionSet fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final questionList = (data['questions'] as List<dynamic>?)?.map((item) => Question.fromMap(item as Map<String, dynamic>)).toList() ?? [];
    return QuestionSet(
      setName: data['setName'],
      isActive: data['isActive'] ?? true,
      questions: questionList,
    );
  }
}
