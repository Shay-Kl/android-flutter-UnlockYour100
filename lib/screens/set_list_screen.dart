import 'package:flutter/material.dart';
import 'package:project/screens/question_list_screen.dart';
import '../models/set.dart';
import 'package:provider/provider.dart';
import '../providers/set_provider.dart';
import '../providers/theme_provider.dart';
import '../models/colors.dart';

class SetListScreen extends StatefulWidget {
  const SetListScreen({super.key});

  @override
  State<SetListScreen> createState() => _SetListScreenState();
}

class _SetListScreenState extends State<SetListScreen> {
  void _showNewSetDialog() {
    final TextEditingController controller = TextEditingController();
    ColorSchemeKey selectedColorKey =
        ColorSchemeKey.Default; // Default color key

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Set'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'New set name'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 180, // Fixed height for the color grid
                    width: double.maxFinite,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),  
                      itemCount: ColorSchemeKey.values.length,
                      itemBuilder: (context, index) {
                        final colorKey = ColorSchemeKey.values[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedColorKey = colorKey;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorKey.getColorFromScheme(
                                  Theme.of(context).colorScheme),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColorKey == colorKey
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                width: selectedColorKey == colorKey ? 3 : 1,
                              ),
                            ),
                            child: selectedColorKey == colorKey
                                ? Icon(
                                    Icons.check,
                                    color: colorKey.getTextColorFromScheme(
                                        Theme.of(context).colorScheme),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      Provider.of<SetProvider>(context, listen: false)
                          .createSet(newName, selectedColorKey);
                    }
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _calculateSuccessRate(QuestionSet s) {
    int totalCorrect = 0;
    int totalAnswers = 0;

    for (var question in s.questions) {
      totalCorrect += question.correctAnswers;
      totalAnswers += question.totalAnswers;
    }

    return totalAnswers == 0 ? 0.0 : totalCorrect / totalAnswers;
  }

  @override
  Widget build(BuildContext context) {
    final setProvider = Provider.of<SetProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
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
              padding: const EdgeInsets.all(16),
              itemCount: questionSets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final set = questionSets[index];
                final totalQuestions = set.questions.length;
                return Card.outlined(
                  color: set.selectedColorKey
                      .getColorFromScheme(Theme.of(context).colorScheme),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: set.selectedColorKey.getBorderColorFromScheme(
                          Theme.of(context).colorScheme),
                      width: 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    title: Text(
                      set.setName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: set.selectedColorKey
                            .getTextColorFromScheme(Theme.of(context).colorScheme),
                      ),
                    ),
                    subtitle: Text(
                      totalQuestions == 0
                          ? 'Empty set'
                          : totalQuestions == 1
                              ? '$totalQuestions question'
                              : '$totalQuestions questions',
                      style: TextStyle(
                        fontSize: 12,
                        color: set.selectedColorKey
                            .getTextColorFromScheme(Theme.of(context).colorScheme),
                      ),
                    ),
                    trailing: Switch(
                      value: set.isActive,
                      onChanged: (bool value) {
                        setProvider.updateSetIsActive(set.setName, value);
                      },
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionListScreen(set),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewSetDialog,
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}
