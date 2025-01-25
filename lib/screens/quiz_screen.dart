import 'package:flutter/material.dart';
import '../models/question.dart';
import '../providers/set_provider.dart';
import 'package:provider/provider.dart';
import '../models/colors.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
//import '../providers/theme_provider.dart';
//import '../models/set.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _controllerBottomCenter;
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

  void playSound() async {
    await _audioPlayer.play(AssetSource('ding.mp3'));
  }

  @override
  void initState() {
    super.initState();
    _controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controllerBottomCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);
    final setProvider = Provider.of<SetProvider>(context);
    if (setStateChange == false) {
      List<Question> questions = _fetchActiveQuestions(setProvider);
      if (!areListsEqual(questions, this.questions)) {
        this.questions = questions;
        questions.shuffle();
        /*
        questions.sort((a, b) {
          final ratioA =
              a.totalAnswers == 0 ? 0 : a.correctAnswers / a.totalAnswers;
          final ratioB =
              b.totalAnswers == 0 ? 0 : b.correctAnswers / b.totalAnswers;
          return ratioA.compareTo(ratioB);
        });
        */
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
        title: const Text("UnlockYour100"),
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
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card.outlined(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8.0), // Optional, for rounded corners
                      side: BorderSide(
                        color: setProvider
                            .getSetByName(question!.setName)
                            .selectedColorKey
                            .getBorderColorFromScheme(
                                Theme.of(context).colorScheme), // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    color: setProvider
                        .getSetByName(question!.setName)
                        .selectedColorKey
                        .getColorFromScheme(Theme.of(context).colorScheme),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize
                            .min, // Ensures the column takes minimal vertical space
                        children: [
                          Text(
                            question!.question,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: setProvider
                                  .getSetByName(question!.setName)
                                  .selectedColorKey
                                  .getTextColorFromScheme(
                                      Theme.of(context).colorScheme),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                              height:
                                  8), // Spacer between the question and setName
                          Text(
                            question!.setName, // Display the setName here
                            style: TextStyle(
                              fontSize: 14,
                              color: setProvider
                                  .getSetByName(question!.setName)
                                  .selectedColorKey
                                  .getTextColorFromScheme(
                                      Theme.of(context).colorScheme),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                              height:
                                  8), // Spacer between the question and setName
                          Text(
                            '${currentIndex+1}/${questions.length}', // Display the setName here
                            style: TextStyle(
                              fontSize: 14,
                              color: setProvider
                                  .getSetByName(question!.setName)
                                  .selectedColorKey
                                  .getTextColorFromScheme(
                                      Theme.of(context).colorScheme),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Spacer
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ConfettiWidget(
                      confettiController: _controllerBottomCenter,
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.5,
                      colors: const [Colors.green, Colors.red, Colors.yellow, Colors.purpleAccent],
                      numberOfParticles: 20,
                    ),
                  ),
                  if (hasAnswered) ...[
                    //final isCorrect = answer == question!.correctAnswer;
                    //final isSelected = selectedAnswer == answer;
                    if (question!.explanation.isNotEmpty) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 0),
                      curve: Curves.fastOutSlowIn,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: null,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              question!.explanation,
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  AnimatedContainer(
                      duration: const Duration(milliseconds: 0),
                      curve: Curves.fastOutSlowIn,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: null,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              question!.correctAnswer,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (question!.correctAnswer != selectedAnswer) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 0),
                      curve: Curves.fastOutSlowIn,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: null,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              selectedAnswer!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  ]
                  else ...[
                  // Answer cards
                  ...shuffledAnswers.map((answer) {
                    final isCorrect = answer == question!.correctAnswer;
                    final isSelected = selectedAnswer == answer;
                    return AnimatedContainer(
                      duration: isSelected
                          ? const Duration(milliseconds: 0)
                          : const Duration(milliseconds: 0),
                      curve: Curves.fastOutSlowIn,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isCorrect
                                ? Colors.green.shade900
                                : Colors.red.shade900)
                            : (isCorrect && selectedAnswer != null
                                ? Colors.green.shade900
                                : colorScheme.surfaceContainer),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: selectedAnswer == null
                              ? () {
                                  setState(() {
                                    setStateChange = true;
                                    selectedAnswer = answer;
                                    hasAnswered = true;
                                    if (answer == question!.correctAnswer) {
                                      _controllerBottomCenter.play();
                                      playSound();
                                    }
                                    setProvider.updateQuestionSuccessRate(
                                        question!,
                                        answer == question!.correctAnswer);
                                    if (answer == question!.correctAnswer) {
                                      question!.correctAnswers =
                                          question!.correctAnswers + 1;
                                    }
                                    question!.totalAnswers =
                                        question!.totalAnswers + 1;
                                  });
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              answer,
                              style: TextStyle(
                                fontSize: 18,
                                color: (isSelected ||
                                        (isCorrect && selectedAnswer != null))
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  ],
                ],
              )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: FilledButton(
          style: TextButton.styleFrom(
            backgroundColor: hasAnswered
                ? colorScheme.primary
                : colorScheme.surfaceContainer,
          ),
          onPressed: () {
            setState(() {
              if (hasAnswered) {
                setStateChange = true;
                if (currentIndex != questions.length - 1) {
                  currentIndex = currentIndex + 1;
                } else {
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
          child: Text(
            'Next Question',
            style: TextStyle(
                color: hasAnswered
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
