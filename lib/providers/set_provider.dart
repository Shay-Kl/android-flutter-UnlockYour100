import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/set.dart';
import '../models/question.dart';

class SetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userEmail;
  late CollectionReference<Map<String, dynamic>>  _setCollection;

  SetProvider(this.userEmail){
    if (!userEmail.isEmpty) {
     _setCollection = _firestore.collection('users').doc(userEmail).collection('sets');
    }
  }

  Future<void> updateSetIsActive(String setName, bool isActive) async {
    try {
      await _setCollection.doc(setName).update({
        'isActive': isActive,
      });
      // After updating Firestore, notify listeners to reflect the change locally
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating isActive: $e");
    }
  }

  Future<void> updateQuestionSuccessRate(Question question, bool success) async {
    //i need to find set - may be store it in the question
    //in the set find question
    //if success increase correctAnswers
    //increase totalAnswers
    //notifyListeners
    //try catch errors
  }

  void notify(){
    notifyListeners();
  }

  Future<void> createSet(String name) async {
    try {
      await _setCollection.doc(name).set({
        'isActive': true,
        'setName': name,
      });
      notifyListeners();
      } catch (e) {
      debugPrint("Error creating set: $e");
    }
  }

  Future<List<QuestionSet>> readSetsForUser() async {
    try{
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
    } catch (e) {
      debugPrint("Error reading set: $e");
      return [];
    }
  }



  Future<List<String>> getSetNames() async {
    try {
      final setsSnapshot = await _setCollection.get();
      return setsSnapshot.docs.map((doc) => doc.id).toList();
    }
    catch (e) {
      debugPrint("Error getting set name: $e");
      return [];
    }
  }

  Future<void> deleteSet(String setName) async {
    try {
    final setRef = _setCollection.doc(setName);

    final questionsSnapshot = await setRef.collection('questions').get();
    for (final doc in questionsSnapshot.docs) {
      await doc.reference.delete();
    }

    await setRef.delete();
    notifyListeners();
    } catch (e) {
      debugPrint("Error deleting set: $e");
    }
  }
}
