import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/set.dart';
import '../models/question.dart';
import '../models/colors.dart';
import 'package:intl/intl.dart';
import 'dart:async';


class SetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userEmail;
  late CollectionReference<Map<String, dynamic>>  _setCollection;
  List<QuestionSet> _sets = [];
  List<QuestionSet> get sets => _sets;
  StreamSubscription? _firestoreSubscription;

  SetProvider(this.userEmail){
    if (userEmail.isNotEmpty) {
     _setCollection = _firestore.collection('users').doc(userEmail).collection('sets-sprint2');
    }
  }

  Future<void> initialize() async {
    if (userEmail.isEmpty) return;
    _listenToFirestore();
  }

  QuestionSet getSetByName(String setName) {
    try {
      return _sets.firstWhere((set) => set.setName == setName, orElse: () => QuestionSet(setName: '', isActive: false, questions: []));
    } catch (e) {
      debugPrint("getSetByName: Error getting set by name: $e");
      return QuestionSet(setName: '', isActive: false, questions: []);
    }
  }

  void _listenToFirestore() {
    try {
      _firestoreSubscription = _setCollection.snapshots().listen((snapshot) async {
        final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Check if user logged in and answered questions today
      final activityDocRef = _firestore
          .collection('users')
          .doc(userEmail)
          .collection('activity')
          .doc(today);


      final List<Future<QuestionSet>> setFutures = [];
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        setFutures.add(_fetchSetWithQuestions(doc, ));

      }
      // Wait for all QuestionSets to be fetched concurrently
      final updatedSets = await Future.wait(setFutures);
      await batch.commit();
      // Update state
      if (!_areSetsEqual(_sets, updatedSets)) {
      _sets = updatedSets;
      notifyListeners();
    }
    });
  } catch (e) {
    debugPrint("listenToFirestore: Error reading set: $e");
    _sets = [];
  }
}

@override
  void dispose() {
    _firestoreSubscription?.cancel(); // Cancel listener on logout
    super.dispose();
  }

Future<QuestionSet> _fetchSetWithQuestions(DocumentSnapshot doc) async {
  try {
    final data = doc.data() as Map<String, dynamic>;
    // Fetch questions for this set
    final questionsSnapshot = await doc.reference.collection('questions').get();
  
  final questions = questionsSnapshot.docs.map((qDoc) {
    final question = Question.fromDocument(qDoc);
    return question;
  }).toList();
    // Create and return the QuestionSet
    return QuestionSet.fromFirestore(data, questions);
  } catch (e) {
    debugPrint("fetchSetWithQuestions: Error fetching questions for set ${doc.id}: $e");
    return QuestionSet(
      id: doc.id,
      setName: "Error Loading Set",
      isActive: false,
      questions: [],
      selectedColorKey: ColorSchemeKey.Default, // Replace with a default value
    );
  }
}

bool _areSetsEqual(List<QuestionSet> oldSets, List<QuestionSet> newSets) {
  // Check if the length of the sets is different
  if (oldSets.length != newSets.length) return false;

  // Check if the set names or any other identifying property has changed
  for (int i = 0; i < oldSets.length; i++) {
    if (oldSets[i].id != newSets[i].id ||
        oldSets[i].setName != newSets[i].setName ||
        oldSets[i].questions.length != newSets[i].questions.length) {
      return false;
    }
    for (int j = 0; j < oldSets[i].questions.length; j++) {
      if (oldSets[i].questions[j].id != newSets[i].questions[j].id ||
          oldSets[i].questions[j].question != newSets[i].questions[j].question ||
          oldSets[i].questions[j].correctAnswer != newSets[i].questions[j].correctAnswer ||
          oldSets[i].questions[j].wrongAnswers.length != newSets[i].questions[j].wrongAnswers.length||
          oldSets[i].questions[j].explanation != newSets[i].questions[j].explanation ||
          oldSets[i].questions[j].correctAnswers != newSets[i].questions[j].correctAnswers ||
          oldSets[i].questions[j].totalAnswers != newSets[i].questions[j].totalAnswers ||
          oldSets[i].questions[j].setName != newSets[i].questions[j].setName)
          {
        return false;
      }
      for (int k = 0; k < oldSets[i].questions[j].wrongAnswers.length; k++) {
        if (oldSets[i].questions[j].wrongAnswers[k] != newSets[i].questions[j].wrongAnswers[k]) {
          return false;
        }
      }
    }
  }
  return true;
}

  

  Future<void> updateSetIsActive(String setName, bool isActive) async {
    try {
      late String setId;
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex == -1) {
        throw Exception("Set with name '$setName' not found.");
      }
      setId = _sets[setIndex].id!;
      _sets[setIndex].isActive = isActive;
      await _setCollection.doc(setId).update({
        'isActive': isActive,
      });
      // After updating Firestore, notify listeners to reflect the change locally
      notifyListeners();
    } catch (e) {
      debugPrint("updateSetIsActive: Error updating isActive: $e");
    }
  }

   Future<void> updateSetColorAndName(String setName, ColorSchemeKey colorKey, String newName) async {
    try {
      late String setId;
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex == -1) {
        throw Exception("Set with name '$setName' not found.");
      }
      setId = _sets[setIndex].id!;
      _sets[setIndex].selectedColorKey = colorKey;
      _sets[setIndex].setName = newName;
      for (final question in _sets[setIndex].questions) {
        question.setName = newName; 
      }
      await _setCollection.doc(setId).update({
        'selectedColorKey': colorKey.toKeyString(),
        'setName': newName,
      });
      final questionsSnapshot = await _setCollection.doc(setId).collection('questions').get();
      for (final questionDoc in questionsSnapshot.docs) {
        await questionDoc.reference.update({'setName': newName});
      }
      // After updating Firestore, notify listeners to reflect the change locally
      notifyListeners();
    } catch (e) {
      debugPrint("updateSetColorAndName: Error updating color and name: $e");
    }
   }

  Future<void> updateQuestionSuccessRate(Question question, bool success) async {
  try {
      late String setId;
      final setIndex = _sets.indexWhere((set) => set.setName == question.setName);
      if (setIndex == -1) {
        throw Exception("Set with name '${question.setName}' not found.");
      }
      setId = _sets[setIndex].id!;
      // Reference to today's activity document
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final activityDocRef = _firestore
          .collection('users')
          .doc(userEmail)
          .collection('activity')
          .doc(today);

      final questionUpdate = {
        'correctAnswers': question.correctAnswers + (success ? 1 : 0),
        'totalAnswers': question.totalAnswers + 1,
        'lastAnswered': FieldValue.serverTimestamp(),
      };

      // Firestore batch for atomic updates
      final batch = _firestore.batch();

      // Update the specific question document
      final questionRef = _setCollection
          .doc(setId)
          .collection('questions')
          .doc(question.id);

      batch.update(questionRef, questionUpdate);

      // Update today's activity document
      batch.set(activityDocRef, {
        'answeredQuestions': FieldValue.increment(1),
        'answeredCorrectly': FieldValue.increment(success ? 1 : 0),
      }, SetOptions(merge: true));

      // Commit Firestore batch
      await batch.commit();

      // Update local cache
      final questionIndex =
          _sets[setIndex].questions.indexWhere((q) => q.id == question.id);
      if (questionIndex != -1) {
        _sets[setIndex].questions[questionIndex].correctAnswers += (success ? 1 : 0);
        _sets[setIndex].questions[questionIndex].totalAnswers += 1;
        _sets[setIndex].questions[questionIndex].lastAnswered = DateTime.now();
      }

      // Notify listeners to update UI
      notifyListeners();
  } catch (e) {
    debugPrint("updateQuestionSuccessRate: Error updating question success rate: $e");
  }
}

  Future<void> createSet(String name, ColorSchemeKey colorKey) async {
    try {
      // Create a new document with an auto-generated ID
    final docRef = _setCollection.doc();
    
    // Initialize the set with the new ID
    QuestionSet set = QuestionSet(
      id: docRef.id, // Set the generated ID
      setName: name,
      isActive: true,
      questions: [],
      selectedColorKey: colorKey,
    );

    // Save the set to Firestore
    await docRef.set(set.toMap());

    final setIndex = _sets.indexWhere((setCompare) => setCompare.id == set.id);
    if (setIndex == -1) {
      _sets.add(set);
    }

    notifyListeners();
      } catch (e) {
      debugPrint("createSet: Error creating set: $e");
    }
  }

  Future<void> deleteSet(String setName) async {
    try {
    late String setId;
    final setIndex = _sets.indexWhere((set) => set.setName == setName);
    if (setIndex == -1) {
      throw Exception("Set with name '$setName' not found.");
    }
    setId = _sets[setIndex].id!;
    _sets.removeWhere((set) => set.setName == setName);
    final setRef = _setCollection.doc(setId);

    final questionsSnapshot = await setRef.collection('questions').get();
    for (final doc in questionsSnapshot.docs) {
      await doc.reference.delete();
    }

    await setRef.delete();
    notifyListeners();
    } catch (e) {
      debugPrint("deleteSet: Error deleting set: $e");
    }
  }
  
  Future<void> addQuestionToSet(String setName,  Question newQuestion) async{
    try {
  
      late String setId;
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex == -1) {
        throw Exception("Set with name '$setName' not found.");
      }
      setId = _sets[setIndex].id!;
      final setRef = _setCollection.doc(setId);
      final docRef = await setRef.collection('questions').add(newQuestion.toMap());
      newQuestion.id = docRef.id;
      _sets[setIndex].questions.add(newQuestion);
      await docRef.update({'id': newQuestion.id});
      notifyListeners();
    } catch (e) {
      debugPrint("addQuestionToSet: Error adding question to set: $e");
    }
  }

  Future<void> updateQuestionInSet(String setName, Question editedQuestion) async{
    try {
      late String setId;
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex == -1) {
        throw Exception("Set with name '$setName' not found.");
      }
      final questionIndex = _sets[setIndex].questions.indexWhere((q) => q.id == editedQuestion.id);
      _sets[setIndex].questions[questionIndex] = editedQuestion;
      setId = _sets[setIndex].id!;
      final setRef = _setCollection.doc(setId);
      if (questionIndex < 0 || questionIndex >= _sets[setIndex].questions.length) {
        throw Exception("Invalid question index.");
      }
      final questionId = editedQuestion.id;
      await setRef.collection('questions').doc(questionId).update(editedQuestion.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint("updateQuestionInSet: Error updating question in set: $e");
    }
  }

  Future<void> deleteQuestionFromSet(String setName, String? id) async {
    try {
      late String setId;
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex == -1) {
        throw Exception("Set with name '$setName' not found.");
      }
      _sets[setIndex].questions.removeWhere((question) => question.id == id);
      setId = _sets[setIndex].id!;
      final setRef = _setCollection.doc(setId);
      final questionId = id;
      await setRef.collection('questions').doc(questionId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint("deleteQuestionFromSet: Error deleting question from set: $e");
    } 
  }
  bool setExists(String setName) {
    return _sets.any((set) => set.setName == setName);
  }
}

