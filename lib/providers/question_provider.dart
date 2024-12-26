import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';

class QuestionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Question> createQuestionForUser(Question q, String userEmail, String setName) async {
    try {
      // users -> userEmail -> sets -> setName -> questions
      final questionCollection = _firestore.collection('users').doc(userEmail).collection('sets').doc(setName).collection('questions');
      final docRef = await questionCollection.add(q.toMap());
      q.id = docRef.id;
      await docRef.update({'id': q.id});
      notifyListeners();

      return q;
    } catch (e) {
      print('Error creating question for user: $e');
      rethrow;
    }
  }

  Future<List<Question>> readQuestionsForUser(String userEmail, String setName) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userEmail).collection('sets').doc(setName).collection('questions').get();
      return snapshot.docs.map((doc) => Question.fromDocument(doc)).toList();
    } catch (e) {
      print('Error reading questions for user: $e');
      return [];
    }
  }

  Future<void> updateQuestionForUser(Question q, String userEmail, String setName) async {
    try {
      if (q.id == null) {
        throw Exception("Question ID is null. Cannot update.");
      }

      final questionDoc = _firestore.collection('users').doc(userEmail).collection('sets').doc(setName).collection('questions').doc(q.id);
      await questionDoc.update(q.toMap());
      notifyListeners();
    } catch (e) {
      print('Error updating question for user: $e');
    }
  }

  Future<void> deleteQuestionForUser(Question q, String userEmail, String setName) async {
    try {
      if (q.id == null) {
        throw Exception("Question ID is null. Cannot delete.");
      }
      final questionDoc = _firestore.collection('users').doc(userEmail).collection('sets').doc(setName).collection('questions').doc(q.id);
      await questionDoc.delete();

      notifyListeners();
    } catch (e) {
      print('Error deleting question for user: $e');
    }
  }
}
