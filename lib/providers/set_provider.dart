import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/set.dart';
import '../models/question.dart';

class SetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userEmail;
  CollectionReference<Map<String, dynamic>> get _setCollection =>
      _firestore.collection('users').doc(userEmail).collection('sets');

  SetProvider(this.userEmail);

  Future<void> createSet(String name) async {
    await _setCollection.doc(name).set({
      'isActive': true,
      'setName': name,
    });
    notifyListeners();
  }

  Future<List<QuestionSet>> readSetsForUser() async {
    final setsSnapshot = await _setCollection.get();
    final List<QuestionSet> sets = [];
    for (final doc in setsSnapshot.docs) {
      final data = doc.data();
      final setName = data['setName'] as String;
      final isActive = data['isActive'] as bool? ?? true;
      final questionsSnap =
          await _setCollection.doc(setName).collection('questions').get();
      final List<Question> questionList = questionsSnap.docs
          .map((qDoc) => Question.fromDocument(qDoc))
          .toList();
      sets.add(QuestionSet(
        setName: setName,
        isActive: isActive,
        questions: questionList,
      ));
    }
    return sets;
  }

  Future<List<String>> getSetNames() async {
    final setsSnapshot = await _setCollection.get();
    return setsSnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> deleteSet(String setName) async {
    final setRef = _setCollection.doc(setName);

    final questionsSnapshot = await setRef.collection('questions').get();
    for (final doc in questionsSnapshot.docs) {
      await doc.reference.delete();
    }

    await setRef.delete();
    notifyListeners();
  }
}
