import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsManager extends ChangeNotifier {
  SettingsManager._privateConstructor() {
    _prefs = Map<String, dynamic>.from(_defaults);
  }

  final Map<String, dynamic> _defaults = {'model': 'gemini-1.5-flash', 'theme': 'Use device theme'};
  Map<String, dynamic> _prefs = {};
  static final SettingsManager _instance = SettingsManager._privateConstructor();
  static SettingsManager get instance => _instance;
  late String userEmail;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> load(String userEmail) async {
    this.userEmail = userEmail;
    final doc = await _firestore.collection('users').doc(userEmail).collection('settings').doc('preferences').get();
    _prefs = Map<String, dynamic>.from(_defaults);
    if (doc.exists && doc.data() != null) {
      _prefs.addAll(doc.data()!);
    }
    notifyListeners();
  }

  Future<void> update(String field, dynamic value) async {
    _prefs[field] = value;
    await _firestore.collection('users').doc(userEmail).collection('settings').doc('preferences').set(_prefs);
    notifyListeners();
  }

  String get model => _prefs['model'];
  String get theme => _prefs['theme'];

  Map<String, String> get current => {
        'model': model,
        'theme': theme,
      };
}
