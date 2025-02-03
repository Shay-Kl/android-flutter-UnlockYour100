import 'package:flutter/material.dart';
import 'package:project/models/set.dart';
import 'package:project/screens/question_list_screen.dart';
import 'package:project/widgets/set_creator_dialog.dart';
import 'package:provider/provider.dart';
import '../providers/set_provider.dart';
//import '../providers/theme_provider.dart';
import '../models/colors.dart';

class SetListScreen extends StatefulWidget {
  const SetListScreen({super.key});

  @override
  State<SetListScreen> createState() => _SetListScreenState();
}

class _SetListScreenState extends State<SetListScreen> {
  @override
  Widget build(BuildContext context) {
    final setProvider = Provider.of<SetProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    //final themeProvider = Provider.of<ThemeProvider>(context);
    final questionSets = List.of(setProvider.sets)
      ..sort((a, b) => a.setName.compareTo(b.setName));

    // Separate into active and inactive sets.
    final activeSets = questionSets.where((set) => set.isActive).toList();
    final inactiveSets = questionSets.where((set) => !set.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: questionSets.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No sets available. Please create a new one to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Column(
                  key: ValueKey('${activeSets.length}-${inactiveSets.length}'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeSets.isNotEmpty) ...[
                      const Text(
                        'Active Sets',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ..._buildSetCards(activeSets, colorScheme, setProvider),
                    ],
                    if (inactiveSets.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Inactive Sets',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ..._buildSetCards(inactiveSets, colorScheme, setProvider),
                    ]
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showNewSetDialog(context, setProvider, true);
          if (result != null) {
            setProvider.createSet(result.name, result.color);
          }
        },
        label: const Text('Add Set'),
        icon: const Icon(Icons.create_new_folder),
      ),
    );
  }

  List<Widget> _buildSetCards(List<QuestionSet> sets, ColorScheme colorScheme,
      SetProvider setProvider) {
    return sets
        .map((set) => Card.outlined(
              key: ValueKey(set.setName),
              color: set.selectedColorKey.getColorFromScheme(colorScheme),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: colorScheme.inverseSurface,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionListScreen(set),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    title: Text(
                      set.setName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      set.questions.isEmpty
                          ? 'Empty set'
                          : set.questionsAnsweredToday == set.questions.length
                              ? 'All ${set.questions.length} questions answered today'
                              : '${set.questionsAnsweredToday}/${set.questions.length} Questions answered today',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: set.isActive,
                      onChanged: (bool value) {
                        setProvider.updateSetIsActive(set.setName, value);
                      },
                    ),
                  ),
                ),
              ),
            ))
        .toList();
  }
}
