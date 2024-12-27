import 'package:flutter/material.dart';
import 'package:project/screens/question_list_screen.dart';
import '../models/set.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/set_provider.dart';

class SetListScreen extends StatefulWidget {
  const SetListScreen({super.key});

  @override
  State<SetListScreen> createState() => _SetListScreenState();
}

class _SetListScreenState extends State<SetListScreen> {
  //final authStatus = context.watch<AuthentificationNotifier>();
  //List<QuestionSet> questionSets = authStatus.Sets;

  late Future<List<QuestionSet>> questionSets;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SetProvider>(context, listen: false);
    questionSets = provider.readSetsForUser('shay.kleiman@gmail.com');
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
                    var userEmail =
                        Provider.of<AuthProvider>(context, listen: false)
                            .userEmail;
                    Provider.of<SetProvider>(context, listen: false)
                        .createSet(userEmail!, newSet);
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
          } else {
            return ListView(
              children: snapshot.data!.map((s) {
                return SetCard(s);
              }).toList(),
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
  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: widget.s.isActive,
      activeColor: Colors.green,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          widget.s.isActive = !widget.s.isActive;
          // TODO: Update the isActive field in Firestore
        });
      },
    );
  }
}

class SetCard extends StatelessWidget {
  final QuestionSet s;
  const SetCard(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 20),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.setName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SwitchExample(s: s),
          ],
        ),
        onTap: () {
          // Navigate to the QuestionListContent screen with the questions
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionListContent(s),
            ),
          );
        },
      ),
    );
  }
}
