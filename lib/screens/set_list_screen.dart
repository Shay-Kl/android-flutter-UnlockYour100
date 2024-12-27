// import 'package:flutter/material.dart';
// import 'question_list_screen.dart';

// class QuestionSetListContent extends StatelessWidget {
//   const QuestionSetListContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Question Set List Screen'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               // Handle settings action
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text('Edit Set'),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const QuestionListContent()),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:project/screens/question_list_screen.dart';
import '../models/set.dart';
import '../models/question.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import '../providers/set_provider.dart';

class QuestionSetListContent extends StatefulWidget {
  const QuestionSetListContent({super.key});

  @override
  State<QuestionSetListContent> createState() => _QuestionSetListContentState();
}

class _QuestionSetListContentState extends State<QuestionSetListContent> {
  //final authStatus = context.watch<AuthentificationNotifier>();
  //List<QuestionSet> questionSets = authStatus.Sets;

  List<QuestionSet> questionSets = [];

  @override
  void initState() {
    super.initState();
    _fetchSetsFromFirestore();
  }

  Future<void> _fetchSetsFromFirestore() async {
    final userEmail = Provider.of<AuthProvider>(context, listen: false).userEmail;
    final provider = Provider.of<SetProvider>(context, listen: false);
    final fetchedSets = await provider.readSetsForUser(userEmail!);
    setState(() {
      questionSets = fetchedSets;
    });
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
                    questionSets.add(newSet);
                    var userEmail = Provider.of<AuthProvider>(context, listen: false).userEmail;
                    Provider.of<SetProvider>(context, listen: false).createSet(userEmail!, newSet);
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
      body: ListView(
        children: questionSets.map((s) {
          return SetCard(s);
        }).toList(),
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
