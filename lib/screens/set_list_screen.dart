import 'package:flutter/material.dart';
import 'package:project/screens/question_list_screen.dart';
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
  void _showNewSetDialog() {
    final TextEditingController controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
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
                  SizedBox(
                    height: 180, // Fixed height for the color grid
                    width: double.maxFinite,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    color: colorScheme.onSurface,
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
                              : totalQuestions == 1
                                  ? '$totalQuestions question'
                                  : '$totalQuestions questions',
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
        onPressed: _showNewSetDialog,
        label: const Text('Create Set'),
        icon: const Icon(Icons.create_new_folder),
      ),
    );
  }
}
