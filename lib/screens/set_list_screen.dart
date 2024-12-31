import 'package:flutter/material.dart';
import 'package:project/screens/question_list_screen.dart';
import '../models/set.dart';
import 'package:provider/provider.dart';
import '../providers/set_provider.dart';

class SetListScreen extends StatefulWidget {
  const SetListScreen({super.key});

  @override
  State<SetListScreen> createState() => _SetListScreenState();
}

class _SetListScreenState extends State<SetListScreen> {
  void _showNewSetDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Set Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'New set name'),
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
                      .createSet(newName);
                }
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Create'),
            ),
          ],
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
      //debugPrint("${question.correctAnswers}/${question.totalAnswers}");
    }

    return totalAnswers == 0 ? 0.0 : totalCorrect / totalAnswers;
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint("set list rebuild");
    final setProvider = Provider.of<SetProvider>(context);
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
                elevation: 4.0,
                child: 
                  ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          set.setName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Questions: $totalQuestions',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Success Rate: $successRate%',
                          style: const TextStyle(fontSize: 14),
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
                        builder: (context) => QuestionListScreen(set.setName),
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
