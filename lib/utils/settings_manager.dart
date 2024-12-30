import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsManager {
  SettingsManager._privateConstructor();
  Map<String, dynamic> _prefs = {};
  static final SettingsManager _instance = SettingsManager._privateConstructor();
  static SettingsManager get instance => _instance;


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> load(String userEmail) async {
    final doc = await _firestore.collection('users').doc(userEmail).collection('settings').doc('preferences').get();
    if (doc.exists && doc.data() != null) {
      _prefs = doc.data()!;
    }
  }

  Future<void> update(String userEmail, String field, dynamic value) async {
    _prefs[field] = value;
    await _firestore.collection('users').doc(userEmail).collection('settings').doc('preferences').set(_prefs);
  }

  String get model => _prefs['model'] ?? 'gemini-1.5-flash';
  String get theme => _prefs['theme'] ?? 'Use device theme';

  Map<String, String> get currentSettings => {
        'model': model,
        'theme': theme,
      };
}
