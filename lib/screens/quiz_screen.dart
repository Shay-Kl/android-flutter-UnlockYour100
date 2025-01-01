import 'package:flutter/material.dart';
import '../models/question.dart';
import '../providers/set_provider.dart';
import 'package:provider/provider.dart';
import '../models/colors.dart';
import '../providers/theme_provider.dart';
//import '../models/set.dart';

class QuizScreen extends StatefulWidget {

  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  String? selectedAnswer;
  List<Question> questions = []; 
  Question? question;
  List<String> shuffledAnswers = [];
  bool hasAnswered = false;
  bool setStateChange = false;

  List<Question> _fetchActiveQuestions(SetProvider setProvider) {
    final sets = setProvider.sets;

    // Filter sets with isActive == true
    final activeSets = sets.where((set) => set.isActive).toList();

    // Combine questions from all active sets
    final List<Question> activeQuestions = [];
    for (final set in activeSets) {
      activeQuestions.addAll(set.questions);
    }

    return activeQuestions;
  }

  bool areListsEqual(List<Question> list1, List<Question> list2) {
  if (list1.length != list2.length) {
    return false; // Lists have different lengths
  }

  // Compare each item in the list
  return list1.every((q1) => list2.contains(q1)); 
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final setProvider = Provider.of<SetProvider>(context);
    if (setStateChange == false){
      List<Question>questions = _fetchActiveQuestions(setProvider);
      if (!areListsEqual(questions, this.questions)) {
        this.questions = questions;
      
        questions.sort((a, b) {
          final ratioA = a.totalAnswers == 0 ? 0 : a.correctAnswers / a.totalAnswers;
          final ratioB = b.totalAnswers == 0 ? 0 : b.correctAnswers / b.totalAnswers;
          return ratioA.compareTo(ratioB);
        });
        currentIndex = 0;
        question = questions.isNotEmpty ? questions[currentIndex] : null;
        shuffledAnswers = question?.getShuffledAnswers() ?? [];
        selectedAnswer = null;
        hasAnswered = false;
      }
    }
    setStateChange = false;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("UnlockYour100!"),
      ),
      body: questions.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No questions available. Please activate an existing set with questions or create a new one and add questions to it to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: setProvider.getSetByName(question!.setName).selectedColorKey.getColorFromScheme(Theme.of(context).colorScheme),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Optional, for rounded corners
                    side: BorderSide(
                      color: setProvider.getSetByName(question!.setName).selectedColorKey.getBorderColorFromScheme(Theme.of(context).colorScheme), // Border color
                      width: 1.0, // Border width
                    ),
                  ),    
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Ensures the column takes minimal vertical space
                      children: [
                        Text(
                          question!.question,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: setProvider.getSetByName(question!.setName).selectedColorKey.getTextColorFromScheme(Theme.of(context).colorScheme),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8), // Spacer between the question and setName
                        Text(
                          question!.setName, // Display the setName here
                          style: TextStyle(
                            fontSize: 16,
                            color: setProvider.getSetByName(question!.setName).selectedColorKey.getTextColorFromScheme(Theme.of(context).colorScheme),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                          setStateChange = true;
                          selectedAnswer = answer;
                          hasAnswered = true;
                          setProvider.updateQuestionSuccessRate(question!, answer == question!.correctAnswer);
                          if (answer == question!.correctAnswer) {
                            question!.correctAnswers = question!.correctAnswers + 1;
                          }
                          question!.totalAnswers = question!.totalAnswers + 1;
                        });
                      }
                    },
                    //TODO: check colors
                    child: Card(
                      elevation: 2.0,
                      color: isSelected
                        ? (isCorrect ? const Color.fromARGB(255, 45, 221, 93) : const Color.fromARGB(255, 251, 66, 90))
                          : (isCorrect && selectedAnswer != null
                            ? const Color.fromARGB(255, 45, 221, 93)
                              : colorScheme.surfaceContainer),
                      child: 
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child:Text(
                            answer,
                            style: TextStyle(
                              fontSize: 18,
                              color: (isSelected || (isCorrect && selectedAnswer != null))
                                  ? const Color.fromARGB(255, 255, 255, 255)
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
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: FilledButton(
              style: TextButton.styleFrom(
                backgroundColor: hasAnswered ? colorScheme.primary : colorScheme.surfaceContainer,
              ),
              onPressed: () {
                setState(() {
                  if (hasAnswered) {
                    setStateChange = true;
                    if (currentIndex != questions.length - 1) {
                      currentIndex = currentIndex + 1;
                    }
                    else {
                      currentIndex = 0;
                    //ScaffoldMessenger.of(context).showSnackBar(
                    //    const SnackBar(content: Text("No more questions!")),
                    //);
                    }
                    selectedAnswer = null;
                    hasAnswered = false;
                    question = questions[currentIndex];
                    shuffledAnswers = question!.getShuffledAnswers();
                  }
                });
              },
              child: Text('Next Question',style: TextStyle(color: hasAnswered ? colorScheme.onPrimary : colorScheme.onSurface),),
            ),
          ),
    );
  }
}
