//import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';
import 'colors.dart';

class QuestionSet {
  String? id;
  String setName;
  bool isActive;
  final List<Question> questions;
  ColorSchemeKey selectedColorKey;
  //usage: set.selectedColorKey.getColorFromScheme(colorScheme);

  QuestionSet(
    {
    this.id,
    required this.setName,
    this.isActive = true,
    required this.questions,
    this.selectedColorKey = ColorSchemeKey.Default,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'setName': setName,
      'isActive': isActive,
      'questions': questions.map((q) => q.toMap()).toList(),
      'selectedColorKey': selectedColorKey.toKeyString(),
    };
  }

  factory QuestionSet.fromFirestore(
    Map<String, dynamic> data,
    List<Question> questions,) 
    {
    final id = data['id'] as String?;
    final setName = data['setName'] as String? ?? 'Unnamed Set';
    final isActive = data['isActive'] as bool? ?? true;
    final selectedColorKey =  data['selectedColorKey'] != null
          ? ColorSchemeKeyExtension.fromKeyString(data['selectedColorKey'])
          : ColorSchemeKey.Default;

    return QuestionSet(
      id: id,
      setName: setName,
      isActive: isActive,
      questions: questions,
      selectedColorKey: selectedColorKey,
    );
  }

  int get questionsAnsweredToday {
    int count = 0;
    for (final question in questions) {
      if (question.isAnsweredToday) {
        count++;
      }
    }
    return count;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuestionSet) return false;
    return id == other.id && setName == other.setName &&
        isActive == other.isActive &&
        questions.length == other.questions.length &&
        questions.every((q) => other.questions.contains(q)) &&
        selectedColorKey == other.selectedColorKey;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        setName.hashCode ^
        isActive.hashCode ^
        questions.hashCode ^
        selectedColorKey.hashCode;
  }
}




