import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/model_manager.dart';

class StatsContent extends StatefulWidget {
  const StatsContent({super.key});

  @override
  State<StatsContent> createState() => _StatsContentState();
}

class _StatsContentState extends State<StatsContent> {
  String _selectedGiminiModel = 'gemini-1.5-flash';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    ModelManager.instance.loadModel(authProvider.userEmail ?? '').then((_) {
      setState(() {
        _selectedGiminiModel = ModelManager.instance.selectedModel;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
                        'gemini-1.5-flash',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('Stable and recommended for most use cases'),
                      value: 'gemini-1.5-flash',
                      groupValue: _selectedGiminiModel,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        setState(() {
                          _selectedGiminiModel = value ?? 'gemini-1.5-flash';
                          ModelManager.instance.updateModel(authProvider.userEmail ?? '', _selectedGiminiModel);
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        'gemini pro',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('Includes experimental features'),
                      value: 'gemini pro',
                      groupValue: _selectedGiminiModel,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        setState(() {
                          _selectedGiminiModel = value ?? 'gemini pro';
                          ModelManager.instance.updateModel(authProvider.userEmail ?? '', _selectedGiminiModel);
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
