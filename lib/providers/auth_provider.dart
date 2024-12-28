import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import settings manager
import '../utils/settings_manager.dart';

class AuthProvider extends ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  // image avatar
  ImageProvider get userImage {
    if (_currentUser?.photoUrl != null) {
      return NetworkImage(_currentUser!.photoUrl!);
    } else {
      return const AssetImage('assets/images/default_avatar.png');
    }
  }

  bool get isSignedIn => _currentUser != null;
  String? get userId => _currentUser?.id;
  String? get userName => _currentUser?.displayName;
  String? get userEmail => _currentUser?.email;

  void setUser(GoogleSignInAccount? user) {
    _currentUser = user;
    // call settings manager to load user settings
    SettingsManager.instance.load(user?.email ?? '');
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    _currentUser = null;
    notifyListeners();
  }
}
