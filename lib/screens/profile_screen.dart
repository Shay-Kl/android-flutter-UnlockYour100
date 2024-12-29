import 'package:flutter/material.dart';
import 'package:project/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/settings_manager.dart';

class StatsContent extends StatefulWidget {
  const StatsContent({super.key});

  @override
  State<StatsContent> createState() => _StatsContentState();
}

class _StatsContentState extends State<StatsContent> {
  static const String FLASH_MODEL = 'gemini-1.5-flash';
  static const String PRO_MODEL = 'gemini-1.5-pro';
  static const String EXP_MODEL = 'gemini-2.0-flash-exp';
  String _selectedGiminiModel = 'gemini-1.5-pro';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    SettingsManager.instance.load(authProvider.userEmail ?? '').then((_) {
      setState(() {
        _selectedGiminiModel = SettingsManager.instance.prefs['model'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (authProvider.isSignedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.signOut(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: authProvider.currentUser?.photoUrl != null
                        ? NetworkImage(authProvider.currentUser!.photoUrl!)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    radius: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authProvider.userName ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    authProvider.userEmail ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Card to hold the RadioListTiles in a more professional look
            Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  children: [
                    const Text(
                      'Choose GIMINI Model:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    RadioListTile<String>(
                      title: const Text(
                        FLASH_MODEL,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('Stable and recommended for most use cases'),
                      value: FLASH_MODEL,
                      groupValue: _selectedGiminiModel,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        setState(() {
                          _selectedGiminiModel = value ?? FLASH_MODEL;
                          SettingsManager.instance.update(authProvider.userEmail ?? '', 'model', _selectedGiminiModel);
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        PRO_MODEL,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('more powerful features'),
                      value: PRO_MODEL,
                      groupValue: _selectedGiminiModel,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        setState(() {
                          _selectedGiminiModel = value ?? PRO_MODEL;
                          SettingsManager.instance.update(authProvider.userEmail ?? '', 'model', _selectedGiminiModel);
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        EXP_MODEL,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('Experimental and cutting-edge features'),
                      value: EXP_MODEL,
                      groupValue: _selectedGiminiModel,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        setState(() {
                          _selectedGiminiModel = value ?? EXP_MODEL;
                          SettingsManager.instance.update(authProvider.userEmail ?? '', 'model', _selectedGiminiModel);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
