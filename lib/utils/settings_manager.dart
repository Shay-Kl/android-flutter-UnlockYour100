import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsManager {
  SettingsManager._privateConstructor();
  Map<String, dynamic> _prefs = {'model': 'gemini-1.5-flash', 'theme': 'light'};
  static final SettingsManager _instance = SettingsManager._privateConstructor();
  static SettingsManager get instance => _instance;

  Map<String, dynamic> get prefs => _prefs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> load(String userEmail) async {
    final doc = await _firestore.collection('users').doc(userEmail).collection('settings').doc('preferences').get();
    if (doc.exists && doc.data() != null) {
      _prefs = doc.data()!;
    }
  }

  Future<void> update(String userEmail, String feild, dynamic value) async {
    _prefs[feild] = value;
    await _firestore.collection('users').doc(userEmail).collection('settings').doc('preferences').set(_prefs);
  }
}
