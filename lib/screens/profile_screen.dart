import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
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
  Map<String, String>? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await SettingsManager.instance.load(authProvider.userEmail ?? '');
    setState(() {
      _settings = SettingsManager.instance.currentSettings;
    });
  }

  void _updateSetting(String key, String value) {
    final email =
        Provider.of<AuthProvider>(context, listen: false).userEmail ?? '';
    SettingsManager.instance.update(email, key, value);

    if (key == 'theme') {
      Provider.of<ThemeProvider>(context, listen: false).setTheme(value);
    }

    setState(() {
      _settings = SettingsManager.instance.currentSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
          _buildPreferences(),
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

  SettingsSection _buildPreferences() {
    return SettingsSection(
      title: const Text('Preferences'),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.auto_awesome),
          title: const Text('Language Model'),
          value: Text(_settings?['model'] ?? ''),
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
          value:
              Text(Provider.of<ThemeProvider>(context).getCurrentThemeName()),
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
        /*
        SettingsTile.navigation(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification Frequency'),
          value: Text(_settings?['notification_frequency'] ?? ''),
          onPressed: (context) => _showOptionsDialog(
            'Notification Frequency',
            'notification_frequency',
            [
              const MapEntry('Never', 'Turn off notifications'),
              const MapEntry('Daily', 'Once a day'),
              const MapEntry('Weekly', 'Once a week'),
              const MapEntry('Monthly', 'Once a month'),
            ],
          ),
        ),
        */
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
      ],
    );
  }

  void _showOptionsDialog(
    String title,
    String settingKey,
    List<MapEntry<String, String>> options,
  ) {
    if (_settings == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((option) => RadioListTile<String>(
                    title: Text(option.key),
                    subtitle:
                        option.value.isNotEmpty ? Text(option.value) : null,
                    value: option.key,
                    groupValue: _settings?[settingKey],
                    onChanged: (value) {
                      if (value != null) {
                        _updateSetting(settingKey, value);
                        Navigator.pop(context);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
