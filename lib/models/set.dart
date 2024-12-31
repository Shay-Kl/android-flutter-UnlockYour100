//import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';
import 'colors.dart';

class QuestionSet {
  final String setName;
  bool isActive;
  final List<Question> questions;
  AppColor selectedColor;

  QuestionSet({
    required this.setName,
    this.isActive = true,
    required this.questions,
    this.selectedColor = AppColor.none,
  });

  Map<String, dynamic> toMap() {
    return {
      'setName': setName,
      'isActive': isActive,
      'questions': questions.map((q) => q.toMap()).toList(),
      'selectedColor': selectedColor.index,
    };
  }

  // static QuestionSet fromDocument(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   final questionList = (data['questions'] as List<dynamic>?)?.map((item) => Question.fromMap(item as Map<String, dynamic>)).toList() ?? [];
  //   return QuestionSet(
  //     setName: data['setName'],
  //     isActive: data['isActive'] ?? true,
  //     questions: questionList,
  //     selectedColor: AppColor.values[data['selectedColor'] as int],
  //   );
  // }

  factory QuestionSet.fromFirestore(
    Map<String, dynamic> data,
    List<Question> questions,) 
    {
    final setName = data['setName'] as String? ?? 'Unnamed Set';
    final isActive = data['isActive'] as bool? ?? true;
    final selectedColorIndex = data['selectedColor'] as int?;
    final selectedColor = selectedColorIndex != null &&
            selectedColorIndex < AppColor.values.length
        ? AppColor.values[selectedColorIndex]
        : AppColor.none;

    return QuestionSet(
      setName: setName,
      isActive: isActive,
      questions: questions,
      selectedColor: selectedColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuestionSet) return false;
    return setName == other.setName &&
        isActive == other.isActive &&
        questions.length == other.questions.length &&
        questions.every((q) => other.questions.contains(q)) &&
        selectedColor == other.selectedColor;
  }

  @override
  int get hashCode {
    return setName.hashCode ^
        isActive.hashCode ^
        questions.hashCode ^
        selectedColor.hashCode;
  }
}




