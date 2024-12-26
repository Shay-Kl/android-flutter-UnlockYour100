import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  String? get userId => _currentUser?.id;
  String? get userName => _currentUser?.displayName;
  String? get userEmail => _currentUser?.email;

  void setUser(GoogleSignInAccount? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    _currentUser = null;
    notifyListeners();
  }
}
