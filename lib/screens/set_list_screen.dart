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
  late Future<List<QuestionSet>> questionSets;
  late final SetProvider _setProvider;
  
  @override
  void initState() {
    super.initState();
    _setProvider = Provider.of<SetProvider>(context, listen: false);
    questionSets = _setProvider.readSetsForUser();
  }

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
                  setState(() {
                    // Add a new QuestionSet with the entered name
                    // questionSets.add(QuestionSet(name: newName, questions: []));
                    final newSet = QuestionSet(setName: newName, questions: []);
                    questionSets.then((sets) {
                      sets.add(newSet);
                    });
                    _setProvider.createSet(newName);
                  });
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

  @override
  Widget build(BuildContext context) {
    debugPrint("set list rebuild");
    final setProvider = Provider.of<SetProvider>(context);
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
      body: FutureBuilder<List<QuestionSet>>(
        future: questionSets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No sets available. Please create a new one to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0), // Optional: Adjust font size for better visibility
                    ),
                  ),
                );
          }
          else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 2, // Adjust the card aspect ratio
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final set = snapshot.data![index];
                return GridTile(
                  child: SetCard(set),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewSetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SwitchExample extends StatefulWidget {
  final QuestionSet s;
  const SwitchExample({super.key, required this.s});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {

  //late final SetProvider _setProvider;
  
  //@override
  //void initState() {
  //  super.initState();
  //  _setProvider = Provider.of<SetProvider>(context, listen: false);
  //}

  @override
  Widget build(BuildContext context) {
    final SetProvider setProvider = Provider.of<SetProvider>(context);
    return Switch(
      // This bool value toggles the switch.
      value: widget.s.isActive,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          widget.s.isActive = !widget.s.isActive;
          setProvider.updateSetIsActive(widget.s.setName, widget.s.isActive);
        });
      },
    );
  }
}

class SetCard extends StatelessWidget {
  final QuestionSet s;
  const SetCard(this.s, {super.key});

  double _calculateSuccessRate() {
    int totalCorrect = 0;
    int totalAnswers = 0;

    for (var question in s.questions) {
      totalCorrect += question.correctAnswers;
      totalAnswers += question.totalAnswers;
      debugPrint("${question.correctAnswers}/${question.totalAnswers}");
    }

    return totalAnswers == 0 ? 0.0 : totalCorrect / totalAnswers;
  }

  @override
  Widget build(BuildContext context) {
    final successRate = (_calculateSuccessRate() * 100).toStringAsFixed(1);
    final totalQuestions = s.questions.length;
    return Card(
      elevation: 4.0,
      child: 
        ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                s.setName,
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
              SwitchExample(s: s),
            ],
          ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionListScreen(s.setName),
            ),
          );
        },
      ),
    );
  }
}
