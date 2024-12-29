import 'package:flutter/material.dart';
import '../models/question.dart';
import '../providers/set_provider.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {

  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  // TODO: Decide how to update list of sets
  late Future<List<Question>> activeQuestionsFuture;
  late final SetProvider _setProvider;
  String? selectedAnswer;
  List<Question> questions = []; 
  Question? question;
  List<String> shuffledAnswers = [];
  bool hasAnswered = false;

  @override
  void initState() {
    super.initState();
    // Shuffle answers only once when the widget is initialized
    _setProvider = Provider.of<SetProvider>(context, listen: false);
    activeQuestionsFuture = _fetchActiveQuestions(_setProvider);
    //shuffledAnswers = question.getShuffledAnswers();
  }

  Future<List<Question>> _fetchActiveQuestions(SetProvider setProvider) async {
    final sets = await setProvider.readSetsForUser();

    // Filter sets with isActive == true
    final activeSets = sets.where((set) => set.isActive).toList();

    // Combine questions from all active sets
    final List<Question> activeQuestions = [];
    for (final set in activeSets) {
      activeQuestions.addAll(set.questions);
    }

    return activeQuestions;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Time!"),
        // TODO: Change this to be UnlockYour100
        actions: [
          if (hasAnswered)
          // TODO: Move this to the bottom of the screen 
          Padding( padding: const EdgeInsets.only(right: 16.0),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                if (currentIndex != questions.length - 1) {
                  currentIndex++;
                  selectedAnswer = null;
                  hasAnswered = false;
                  question = questions[currentIndex];
                  shuffledAnswers = question!.getShuffledAnswers();
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No more questions!")),
                  );
                }
              });
            },
            child: Text(
              'Next', // You can change the text here to something else
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        )],
      ),
      body: FutureBuilder<List<Question>>(
        future: activeQuestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active sets found.'));
          } else {
            if (questions.isEmpty){
              questions = snapshot.data!;
            }
            if (question == null) {
              question = questions[currentIndex];
              shuffledAnswers = question!.getShuffledAnswers();
            }
                  return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question card
                          Card(
                            elevation: 4.0,
                            color: colorScheme.primary,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                question!.question,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: colorScheme.onPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16), // Spacer

                          // Answer cards
                          ...shuffledAnswers.map((answer) {
                            final isCorrect = answer == question!.correctAnswer;
                            final isSelected = selectedAnswer == answer;

                            return GestureDetector(
                              onTap: () {
                                if (selectedAnswer == null) {
                                  setState(() {
                                    // TODO: Update answered fields in the question
                                    selectedAnswer = answer;
                                    hasAnswered = true;
                                  });
                                }
                              },
                              child: Card(
                                elevation: 2.0,
                                color: isSelected
                                    ? (isCorrect ? const Color.fromARGB(255, 0, 110, 66) : const Color.fromARGB(255, 150, 0, 24))
                                    : (isCorrect && selectedAnswer != null
                                        ? const Color.fromARGB(255, 0, 110, 66)
                                        : colorScheme.surfaceContainer),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    answer,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: (isSelected ||
                                              (isCorrect &&
                                                  selectedAnswer != null))
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      )
                  )
                  
                );
              
            
          }
        },
      ),
    );
  }
}