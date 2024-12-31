import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/set.dart';
import '../models/question.dart';

class SetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userEmail;
  late CollectionReference<Map<String, dynamic>>  _setCollection;
  List<QuestionSet> _sets = [];
  List<QuestionSet> get sets => _sets;
  
  SetProvider(this.userEmail){
    if (userEmail.isNotEmpty) {
     _setCollection = _firestore.collection('users').doc(userEmail).collection('sets2');
      _fetchSets(); // Initialize local cache
      _listenToFirestore();
    }
  }

  QuestionSet getSetByName(String setName) {
    try {
      return _sets.firstWhere((set) => set.setName == setName, orElse: () => QuestionSet(setName: '', isActive: false, questions: []));
    } catch (e) {
      debugPrint("getSetByName: Error getting set by name: $e");
      return QuestionSet(setName: '', isActive: false, questions: []);
    }
  }

  Future<void> _fetchSets() async {
  try{
  final snapshot = await _setCollection.get();
  final List<QuestionSet> fetchedSets = [];

  for (final doc in snapshot.docs) {
    final data = doc.data();

    // Fetch questions for this set
    final questionsSnap = await _setCollection
        .doc(doc.id)
        .collection('questions')
        .get();
    final List<Question> questionList = questionsSnap.docs
        .map((qDoc) => Question.fromDocument(qDoc))
        .toList();

    // Create QuestionSet
    fetchedSets.add(QuestionSet.fromFirestore(data, questionList));
  }

  _sets = fetchedSets; 
  notifyListeners();
  } catch (e) {
    debugPrint("fetchSets: Error fetching sets: $e");
    _sets = [];
  }
}

  void _listenToFirestore() {
    try{
  _setCollection.snapshots().listen((snapshot) async {
    final List<QuestionSet> updatedSets = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Fetch questions for this set
      final questionsSnap = await _setCollection
          .doc(doc.id)
          .collection('questions')
          .get();
      final List<Question> questionList = questionsSnap.docs
          .map((qDoc) => Question.fromDocument(qDoc))
          .toList();

      // Create QuestionSet
      updatedSets.add(QuestionSet.fromFirestore(data, questionList));
    }

    _sets = updatedSets;
    notifyListeners();
  });
  } catch (e) {
      debugPrint("listenToFirestore: Error reading set: $e");
      _sets = [];
  }
}

  // Future<List<QuestionSet>> readSetsForUser() async {
  //   try{
  //     final setsSnapshot = await _setCollection.get();
  //     final List<QuestionSet> sets = [];
  //     for (final doc in setsSnapshot.docs) {
  //       final data = doc.data();
  //       final setName = data['setName'] as String? ?? 'Unnamed Set';
  //       final isActive = data['isActive'] as bool? ?? true;
  //       final selectedColorIndex = data['selectedColor'] as int?;
  //       final selectedColor = selectedColorIndex != null && selectedColorIndex < AppColor.values.length
  //         ? AppColor.values[selectedColorIndex]
  //         : AppColor.none;
  //         final questionsSnap =
  //           await _setCollection.doc(setName).collection('questions').get();
  //       final List<Question> questionList = questionsSnap.docs
  //           .map((qDoc) => Question.fromDocument(qDoc))
  //           .toList();
  //       sets.add(QuestionSet(
  //         setName: setName,
  //         isActive: isActive,
  //         questions: questionList,
  //         selectedColor: selectedColor,
  //       ));
  //     }
  //     return sets;
  //   } catch (e) {
  //     debugPrint("readSetsForUser: Error reading set: $e");
  //     return [];
  //   }
  // }

  Future<void> updateSetIsActive(String setName, bool isActive) async {
    try {
      await _setCollection.doc(setName).update({
        'isActive': isActive,
      });
      // After updating Firestore, notify listeners to reflect the change locally
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex != -1) {
        _sets[setIndex].isActive = isActive;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("updateSetIsActive: Error updating isActive: $e");
    }
  }

  Future<void> updateQuestionSuccessRate(Question question, bool success) async {
  try {
    // Update Firestore document for the question in the relevant set
    await _setCollection.doc(question.setName).collection('questions').doc(question.id).update({
      'correctAnswers': question.correctAnswers + (success ? 1 : 0),
      'totalAnswers': question.totalAnswers + 1,
    });

    // After updating Firestore, update the local _sets to reflect the changes
    // final setIndex = _sets.indexWhere((set) => set.setName == question.setName);
    // if (setIndex != -1) {
    //   final questionIndex = _sets[setIndex].questions.indexWhere((q) => q.id == question.id);
    //   if (questionIndex != -1) {
    //     // Update only the specific question fields
    //     _sets[setIndex].questions[questionIndex].correctAnswers += (success ? 1 : 0);
    //     _sets[setIndex].questions[questionIndex].totalAnswers += 1;
    //   }
    // }

    // Notify listeners to update UI with the new question data
    notifyListeners();
  } catch (e) {
    debugPrint("updateQuestionSuccessRate: Error updating question success rate: $e");
  }
}

  Future<void> createSet(String name) async {
    try {
      await _setCollection.doc(name).set({
        'isActive': true,
        'setName': name,
        'selectedColor': 0,
      });
      _sets.add(QuestionSet(setName: name, isActive: true, questions: []));
      notifyListeners();
      } catch (e) {
      debugPrint("createSet: Error creating set: $e");
    }
  }

  Future<List<String>> getSetNames() async {
    try {
      final setsSnapshot = await _setCollection.get();
      return setsSnapshot.docs.map((doc) => doc.id).toList();
    }
    catch (e) {
      debugPrint("getSetNames: Error getting set name: $e");
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
    _sets.removeWhere((set) => set.setName == setName);
    notifyListeners();
    } catch (e) {
      debugPrint("deleteSet: Error deleting set: $e");
    }
  }

  Future<void> addQuestionToSet(String setName,  Question newWuestion) async{
    try {
      final setRef = _setCollection.doc(setName);
      final docRef = await setRef.collection('questions').add(newWuestion.toMap());
      newWuestion.id = docRef.id;
      await docRef.update({'id': newWuestion.id});
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex != -1) {
        _sets[setIndex].questions.add(newWuestion);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("addQuestionToSet: Error adding question to set: $e");
    }
  }

  Future<void> updateQuestionInSet(String setName, int index, Question editedQuestion) async{
    try {
      final setRef = _setCollection.doc(setName);
      final questionId = _sets.firstWhere((set) => set.setName == setName).questions[index].id;
      setRef.collection('questions').doc(questionId).update(editedQuestion.toMap());
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex != -1) {
        _sets[setIndex].questions[index] = editedQuestion;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("updateQuestionInSet: Error updating question in set: $e");
    }
  }

  Future<void> deleteQuestionFromSet(String setName, int index) async {
    try {
      final setRef = _setCollection.doc(setName);
      final questionId = _sets.firstWhere((set) => set.setName == setName).questions[index].id;
      await setRef.collection('questions').doc(questionId).delete();
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex != -1) {
        _sets[setIndex].questions.removeAt(index);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("deleteQuestionFromSet: Error deleting question from set: $e");
    } 
  }
}
  
