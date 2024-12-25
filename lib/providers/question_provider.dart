import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../question.dart';

class QuestionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createQuestion(Question q) async {
    await _firestore.collection('questions').add(q.toMap());
    notifyListeners();
  }

  Future<List<Question>> readAllQuestions() async {
    final snapshot = await _firestore.collection('questions').get();
    return snapshot.docs.map((doc) => Question.fromDocument(doc)).toList();
  }

  Future<void> updateQuestion(String docId, Question newQuestion) async {
    await _firestore.collection('questions').doc(docId).update(newQuestion.toMap());
    notifyListeners();
  }

  Future<void> deleteQuestion(String docId) async {
    await _firestore.collection('questions').doc(docId).delete();
    notifyListeners();
  }
}