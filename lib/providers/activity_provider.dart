import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ActivityProvider extends ChangeNotifier {
  String userEmail;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> _activityCollection;
  List<int> _answeredQuestionsPerDay = [];
  List<int> _answeredCorrectlyPerDay = [];
  List<String> _days = [];
  bool _isLoading = false;
  StreamSubscription? _firestoreSubscription;

  bool get isLoading => _isLoading;
  List<int> get answeredQuestionsPerDay => _answeredQuestionsPerDay;
  List<int> get answeredCorrectlyPerDay => _answeredCorrectlyPerDay;
  List<String> get days => _days;

  ActivityProvider(this.userEmail) {
    if (userEmail.isNotEmpty) {
      _activityCollection = _firestore.collection('users').doc(userEmail).collection('activity');
    }
  }

  Future<void> initialize() async {
    if (userEmail.isEmpty) return;

    await logUserLogin();
    _listenToFirestore();
  }
  
  void _listenToFirestore() {
  try {
    _firestoreSubscription = _activityCollection.snapshots().listen((snapshot) async {
      _isLoading = true;
      final activityMap = <String, List<int>>{}; // key: date, value: [answeredQuestions, answeredCorrectly]

      for (var doc in snapshot.docs) {
        final activityData = doc.data();
        final date = (activityData['lastLogin'] as Timestamp).toDate();
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        final answeredQuestions = activityData['answeredQuestions'] as int? ?? 0;
        final answeredCorrectly = activityData['answeredCorrectly'] as int? ?? 0;
        activityMap[formattedDate] = [answeredQuestions, answeredCorrectly];
      }
      // Re-generate the list of the last 30 days
      DateTime earliestDate = DateTime.now();
      for (var key in activityMap.keys) {
        final parsedDate = DateTime.parse(key);
        if (parsedDate.isBefore(earliestDate)) {
          earliestDate = parsedDate;
        }
      }

      final now = DateTime.now();
      final daysBetween = now.difference(earliestDate).inDays;

      // Generate the entire list of days from the earliest date to today
      final allDays = List.generate(daysBetween + 1, (index) {
        final day = earliestDate.add(Duration(days: index));
        return DateFormat('yyyy-MM-dd').format(day);
      });
      // Populate the answeredQuestionsPerDay and days lists
      List<int> answeredQuestionsPerDay = [];
      List<int> answeredCorrectlyPerDay = [];
      List<String> days = [];

      for (var day in allDays) {
        final activityData = activityMap[day] ?? [0, 0]; // Default to [0, 0] if no data
        answeredQuestionsPerDay.add(activityData[0]); // First element: answered questions
        answeredCorrectlyPerDay.add(activityData[1]); // Second element: answered correctly
        days.add(day);
      }

      const listEquality = ListEquality();
      if (!listEquality.equals(answeredQuestionsPerDay, _answeredQuestionsPerDay) || 
          !listEquality.equals(answeredCorrectlyPerDay, _answeredCorrectlyPerDay) ||
        !listEquality.equals(days, _days)) {
        _answeredQuestionsPerDay = answeredQuestionsPerDay;
        _answeredCorrectlyPerDay = answeredCorrectlyPerDay;
        _days = days;
        _isLoading = false;
        // Notify listeners only if data has changed
        notifyListeners();
      }
    });
  } catch (error) {
    _answeredQuestionsPerDay = [];
    _answeredCorrectlyPerDay = [];
    _days = [];
    _isLoading = false;
    debugPrint("Error listening to Firestore activity data: $error");
  }
}

@override
  void dispose() {
    _firestoreSubscription?.cancel(); // Cancel listener on logout
    super.dispose();
  }

  Future<void> logUserLogin() async {
    if (userEmail.isEmpty) return;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentReference activityDoc = _activityCollection.doc(today);
    try {
      final snapshot = await activityDoc.get();
      if (snapshot.exists) {
      // Check if the fields exist; if not, add default values
      Map<String, dynamic> updatedFields = {};
      final data = snapshot.data() as Map<String, dynamic>?;
      
      if (data == null || !data.containsKey('answeredQuestions')) {
        updatedFields['answeredQuestions'] = 0;
      }
      if (data == null || !data.containsKey('answeredCorrectly')) {
        updatedFields['answeredCorrectly'] = 0;
      }
      if (updatedFields.isNotEmpty) {
        updatedFields['lastLogin'] = FieldValue.serverTimestamp();
        await activityDoc.set(updatedFields, SetOptions(merge: true));
      }
    } else {
      await activityDoc.set({
        'answeredQuestions': 0,
        'answeredCorrectly': 0,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error logging login: $e');
    }
  }
}