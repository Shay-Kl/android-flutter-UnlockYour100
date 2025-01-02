import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/set.dart';
import '../models/question.dart';
import '../models/colors.dart';

class SetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userEmail;
  late CollectionReference<Map<String, dynamic>>  _setCollection;
  List<QuestionSet> _sets = [];
  List<QuestionSet> get sets => _sets;
  
  SetProvider(this.userEmail){
    if (userEmail.isNotEmpty) {
     _setCollection = _firestore.collection('users').doc(userEmail).collection('sets');
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
  try {
    // Fetch all sets
    final snapshot = await _setCollection.get();
    final List<Future<QuestionSet>> setFutures = [];

    for (final doc in snapshot.docs) {
      setFutures.add(_fetchSetWithQuestions(doc));
    }

    // Wait for all sets to be fetched concurrently
    final fetchedSets = await Future.wait(setFutures);

    // Update state
    if (!_areSetsEqual(_sets, fetchedSets)) {
      _sets = fetchedSets;
      notifyListeners();
    }
  } catch (e) {
    debugPrint("fetchSets: Error fetching sets: $e");
    _sets = [];
  }
}

Future<QuestionSet> _fetchSetWithQuestions(QueryDocumentSnapshot doc) async {
  try {
    final data = doc.data() as Map<String, dynamic>;
    // Fetch questions for this set
    final questionsSnap = await _setCollection
        .doc(doc.id)
        .collection('questions')
        .get();
    final List<Question> questionList = questionsSnap.docs
        .map((qDoc) => Question.fromDocument(qDoc))
        .toList();
    // Create and return the QuestionSet
    return QuestionSet.fromFirestore(data, questionList);
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
  }

  return true;
}

  void _listenToFirestore() {
    try {
    _setCollection.snapshots().listen((snapshot) async {
      final List<Future<QuestionSet>> setFutures = [];
      for (final doc in snapshot.docs) {
      setFutures.add(_fetchSetWithQuestions(doc));
    }
      // Wait for all QuestionSets to be fetched concurrently
      final updatedSets = await Future.wait(setFutures);
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
    // Update Firestore document for the question in the relevant set
    await _setCollection.doc(setId).collection('questions').doc(question.id).update({
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

//not updated
  // Future<List<String>> getSetNames() async {
  //   try {
  //     final setsSnapshot = await _setCollection.get();
  //     return setsSnapshot.docs.map((doc) => doc.id).toList();
  //   }
  //   catch (e) {
  //     debugPrint("getSetNames: Error getting set name: $e");
  //     return [];
  //   }
  // }

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
      _sets[setIndex].questions.add(newQuestion);
      setId = _sets[setIndex].id!;
      final setRef = _setCollection.doc(setId);
      final docRef = await setRef.collection('questions').add(newQuestion.toMap());
      newQuestion.id = docRef.id;
      await docRef.update({'id': newQuestion.id});
      notifyListeners();
    } catch (e) {
      debugPrint("addQuestionToSet: Error adding question to set: $e");
    }
  }

  Future<void> updateQuestionInSet(String setName, int index, Question editedQuestion) async{
    try {
      late String setId;
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex == -1) {
        throw Exception("Set with name '$setName' not found.");
      }
      _sets[setIndex].questions[index] = editedQuestion;
      setId = _sets[setIndex].id!;
      final setRef = _setCollection.doc(setId);
      if (index < 0 || index >= _sets[setIndex].questions.length) {
        throw Exception("Invalid question index.");
      }
      final questionId = _sets.firstWhere((set) => set.setName == setName).questions[index].id;
      await setRef.collection('questions').doc(questionId).update(editedQuestion.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint("updateQuestionInSet: Error updating question in set: $e");
    }
  }

  Future<void> deleteQuestionFromSet(String setName, int index) async {
    try {
      late String setId;
      final setIndex = _sets.indexWhere((set) => set.setName == setName);
      if (setIndex == -1) {
        throw Exception("Set with name '$setName' not found.");
      }
      _sets[setIndex].questions.removeAt(index);
      setId = _sets[setIndex].id!;
      final setRef = _setCollection.doc(setId);
      if (index < 0 || index >= _sets[setIndex].questions.length) {
        throw Exception("Invalid question index.");
      }
      final questionId = _sets.firstWhere((set) => set.setName == setName).questions[index].id;
      await setRef.collection('questions').doc(questionId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint("deleteQuestionFromSet: Error deleting question from set: $e");
    } 
  }
}
  
