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
  Future<List<Question>>? activeQuestionsFuture;
  String? selectedAnswer;
  List<Question> questions = []; 
  Question? question;
  List<String> shuffledAnswers = [];
  bool hasAnswered = false;
  bool setStateChange = false;

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
    //debugPrint(setStateChange.toString());
    final setProvider = Provider.of<SetProvider>(context);
    if (setStateChange == false){
      activeQuestionsFuture = _fetchActiveQuestions(setProvider);
      questions = [];
      shuffledAnswers = [];
      question = null;
      currentIndex = 0;
      selectedAnswer = null;
      hasAnswered = false;
    }
    setStateChange = false;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("UnlockYour100!"),
      ),
      body: 
        SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: FutureBuilder<List<Question>>(
            future: activeQuestionsFuture,
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
                      'No questions available. Please activate an existing set with questions or create a new one and add questions to it to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0), // Optional: Adjust font size for better visibility
                    ),
                  ),
                );
              } else {
                  if (questions.isEmpty){
                    questions = snapshot.data!;
                    //debugPrint(questions.length.toString());
                    questions.sort((a, b) {
                      final ratioA = a.totalAnswers == 0 ? 0 : a.correctAnswers / a.totalAnswers;
                      final ratioB = b.totalAnswers == 0 ? 0 : b.correctAnswers / b.totalAnswers;
                    return ratioA.compareTo(ratioB);
                    });
                  }
                  if (question == null) {
                    question = questions[currentIndex];
                    shuffledAnswers = question!.getShuffledAnswers();
                  }
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 4.0,
                          color: colorScheme.primary,
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                              //"${question!.question} ${question!.correctAnswers}/${question!.totalAnswers}",
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
                            child: Card(
                              elevation: 2.0,
                              color: isSelected
                                ? (isCorrect ? const Color.fromARGB(255, 0, 110, 66) : const Color.fromARGB(255, 150, 0, 24))
                                  : (isCorrect && selectedAnswer != null
                                    ? const Color.fromARGB(255, 0, 110, 66)
                                      : colorScheme.surfaceContainer),
                              child: 
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child:Text(
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
                    
                  );
                }  
              }
            )
          ),
          
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: FilledButton(
              style: TextButton.styleFrom(
                backgroundColor: hasAnswered ? colorScheme.primary : colorScheme.surfaceDim,
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
              child: Text('Next Question',style: TextStyle(color: hasAnswered ? colorScheme.onPrimary : colorScheme.outline),),
          ),
      ),
    );
}
}
