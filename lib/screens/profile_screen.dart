import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../utils/settings_manager.dart';
import 'package:project/screens/login_screen.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // -------------------------------------------------------------------------
  // Build Functions
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final settings = Provider.of<SettingsManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showAboutDialog(context),
        ),
      ]),
      body: SettingsList(
        lightTheme: SettingsThemeData(
          settingsListBackground: scaffoldBackgroundColor,
          settingsSectionBackground: scaffoldBackgroundColor,
        ),
        darkTheme: SettingsThemeData(
          settingsListBackground: scaffoldBackgroundColor,
          settingsSectionBackground: scaffoldBackgroundColor,
        ),
        sections: [
          _buildUserProfile(),
          _buildPreferences(settings),
          _buildAccountActions(),
        ],
      ),
    );
  }

  SettingsSection _buildUserProfile() {
    final brightness = Theme.of(context).brightness;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return SettingsSection(tiles: [
      CustomSettingsTile(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: authProvider.currentUser?.photoUrl != null
                    ? NetworkImage(authProvider.currentUser!.photoUrl!)
                    : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
                radius: 40,
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.userName ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                authProvider.userEmail ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: brightness == Brightness.light
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      )
    ]);
  }

  SettingsSection _buildPreferences(SettingsManager settings) {
    return SettingsSection(
      title: const Text('Preferences'),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.auto_awesome),
          title: const Text('Language Model'),
          value: Text(settings.current['model']!),
          onPressed: (context) => _showOptionsDialog(
            'Language Model',
            'model',
            [
              const MapEntry('gemini-1.5-flash', 'Stable and recommended'),
              const MapEntry('gemini-1.5-pro', 'More powerful features'),
              const MapEntry('gemini-2.0-flash-exp', 'Experimental'),
            ],
          ),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.palette),
          title: const Text('Theme'),
          value: Text(settings.current['theme']!),
          onPressed: (context) => _showOptionsDialog(
            'Theme',
            'theme',
            [
              const MapEntry('Light', 'Light theme'),
              const MapEntry('Dark', 'Dark theme'),
              const MapEntry('Use device theme', 'Follow system settings'),
            ],
          ),
        ),
      ],
    );
  }

  SettingsSection _buildAccountActions() {
    return SettingsSection(
      title: const Text('Account'),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Log Out', style: TextStyle(color: Colors.red)),
          onPressed: (context) async {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            await authProvider.signOut(context);
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          },
        ),
        SettingsTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title:
              const Text('Delete Account', style: TextStyle(color: Colors.red)),
          onPressed: (context) {
            _confirmDeleteAccount(context);
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // User Input Handlers
  // -------------------------------------------------------------------------

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'UnlockYour100',
      applicationVersion: '1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
          'assets/icon.png',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      ),
      children: [
        const Text(
          'UnlockYour100 is an educational app designed to help students practice and master their course material through interactive quizzes.',
        ),
      ],
    );
  }

  void _showOptionsDialog(
    String title,
    String settingKey,
    List<MapEntry<String, String>> options,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (option) => RadioListTile<String>(
                  title: Text(option.key),
                  subtitle: option.value.isNotEmpty ? Text(option.value) : null,
                  value: option.key,
                  groupValue:
                      Provider.of<SettingsManager>(context, listen: false)
                          .current[settingKey],
                  onChanged: (value) {
                    if (value != null) {
                      Provider.of<SettingsManager>(context, listen: false)
                          .update(settingKey, value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final parentContext = context; // Capture the parent's context
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('WARNING!'),
        content: const Text(
          'Deleting your account will permanently remove all your data.\n\n'
          'Are you absolutely sure you want to continue?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deleteUserData();
              final authProvider =
                  Provider.of<AuthProvider>(parentContext, listen: false);
              await authProvider.signOut(parentContext);
              if (parentContext.mounted) {
                Navigator.of(parentContext, rootNavigator: true)
                    .pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Use this version of _deleteUserData() to sequentially delete all nested documents,
  // ensuring that every document under the user is deleted before removing the root user document.

  Future<void> _deleteUserData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userEmail = authProvider.userEmail;
      if (userEmail == null || userEmail.isEmpty) return;

      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(userEmail);

      // Delete the 'preferences' document from the 'settings' subcollection
      await userDocRef.collection('settings').doc('preferences').delete();

      // Delete each document in the 'sets' subcollection, along with its nested 'questions'
      final setsSnapshot = await userDocRef.collection('sets').get();
      for (final setDoc in setsSnapshot.docs) {
        // Delete every document in the nested 'questions' subcollection
        final questionsSnapshot =
            await setDoc.reference.collection('questions').get();
        for (final questionDoc in questionsSnapshot.docs) {
          await questionDoc.reference.delete();
        }
        await setDoc.reference.delete();
      }

      // Delete all documents in the 'activity' subcollection
      final activitySnapshot = await userDocRef.collection('activity').get();
      for (final doc in activitySnapshot.docs) {
        await doc.reference.delete();
      }

      // Finally, delete the root user document
      await userDocRef.delete();
    } catch (e) {
      debugPrint('Error deleting user data: $e');
    }
  }
}
