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
  ColorSchemeKey selectedColorKey = ColorSchemeKey.Default; // Default color key

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
                DropdownButton<ColorSchemeKey>(
                  value: selectedColorKey,
                  isExpanded: true,
                  items: ColorSchemeKey.values.map((colorKey) {
                    return DropdownMenuItem<ColorSchemeKey>(
                      value: colorKey,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colorKey.getColorFromScheme(Theme.of(context).colorScheme),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(colorKey.toKeyString()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newColorKey) {
                    setState(() {
                      selectedColorKey = newColorKey!;
                    });
                  },
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
        title: const Text('Question Set List Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings action
            },
          ),
        ],
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
      : GridView.builder(  
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 2, // Adjust the card aspect ratio
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          padding: const EdgeInsets.all(10),
          itemCount: questionSets.length,
          itemBuilder: (context, index) {
            final set = questionSets[index];
            final successRate = (_calculateSuccessRate(set) * 100).toStringAsFixed(1);
            final totalQuestions = set.questions.length;
            return GridTile(
              child: Card(
                color: set.selectedColorKey.getColorFromScheme(Theme.of(context).colorScheme),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Optional, for rounded corners
                    side: BorderSide(
                      color: set.selectedColorKey.getBorderColorFromScheme(Theme.of(context).colorScheme), // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                elevation: 4.0,
                child: 
                  ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          set.setName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: set.selectedColorKey.getTextColorFromScheme(Theme.of(context).colorScheme),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Questions: $totalQuestions',
                          style: TextStyle(fontSize: 14, color: set.selectedColorKey.getTextColorFromScheme(Theme.of(context).colorScheme)),
                        ),
                        Text(
                          'Success Rate: $successRate%',
                          style: TextStyle(fontSize: 14,color: set.selectedColorKey.getTextColorFromScheme(Theme.of(context).colorScheme)),
                        ),
                        Switch(
                          // This bool value toggles the switch.
                          value: set.isActive,
                          onChanged: (bool value) {
                            // This is called when the user toggles the switch.
                            setProvider.updateSetIsActive(
                              set.setName, value);
                          },
                        ),
                      ],
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
              ),
            );
          },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewSetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
