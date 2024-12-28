import 'package:cloud_firestore/cloud_firestore.dart';

class ModelManager {
  ModelManager._privateConstructor();
  static final ModelManager _instance = ModelManager._privateConstructor();
  static ModelManager get instance => _instance;

  String _selectedModel = 'gemini-1.5-flash';
  String get selectedModel => _selectedModel;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadModel(String userEmail) async {
    final doc = await _firestore.collection('users').doc(userEmail).collection('settings').doc('preferences').get();
    if (doc.exists && doc.data() != null) {
      _selectedModel = doc.data()!['model'] ?? 'gemini-1.5-flash';
    }
  }

  Future<void> updateModel(String userEmail, String newModel) async {
    _selectedModel = newModel;
    await _firestore.collection('users').doc(userEmail).collection('settings').doc('preferences').set({'model': newModel});
  }
}
