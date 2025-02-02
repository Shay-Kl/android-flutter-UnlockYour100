import 'package:flutter/material.dart';
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
    final questionSets = setProvider.sets;
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
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: questionSets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final set = questionSets[index];
                final totalQuestions = set.questions.length;
                final answeredQuestions = set.questionsAnsweredToday;
                bool completed = answeredQuestions == totalQuestions;
                return Card.outlined(
                  color: set.selectedColorKey
                      .getColorFromScheme(Theme.of(context).colorScheme),
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
                          totalQuestions == 0
                              ? 'Empty set'
                              : (answeredQuestions == totalQuestions)
                                  ? 'All $totalQuestions questions answered today'
                                  : '$answeredQuestions/$totalQuestions Questions answered today',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
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
                );
              },
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
}
