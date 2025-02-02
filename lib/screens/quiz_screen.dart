import 'package:flutter/material.dart';
import 'package:project/widgets/mixed_text.dart';
import '../models/question.dart';
import '../providers/set_provider.dart';
import 'package:provider/provider.dart';
import '../models/colors.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
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
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setProvider = Provider.of<SetProvider>(context);
    if (setStateChange == false) {
      List<Question> questions = _fetchActiveQuestions(setProvider);
      if (!areListsEqual(questions, this.questions)) {
        this.questions = questions;
        // Sorting questions: First by answeredToday, then by correctAnswers/totalAnswers ratio
        questions.sort((a, b) {
          // Primary sort by answeredToday
          final answeredTodayA = a.answeredToday;
          final answeredTodayB = b.answeredToday;
          if (answeredTodayA != answeredTodayB) {
            return answeredTodayB
                .compareTo(answeredTodayA); // 1 should come before 0
          }

          // Secondary sort by correctAnswers/totalAnswers ratio
          final ratioA =
              a.totalAnswers == 0 ? 0 : a.correctAnswers / a.totalAnswers;
          final ratioB =
              b.totalAnswers == 0 ? 0 : b.correctAnswers / b.totalAnswers;
          return ratioB.compareTo(ratioA); // Higher ratio should come first
        });

        // Set currentIndex to the first question with answeredToday == 0
        currentIndex =
            questions.indexWhere((question) => question.answeredToday == 0);

        // If all questions are answered, set currentIndex to the last question
        if (currentIndex == -1) {
          currentIndex = questions.length - 1; // Last question
        }
        question = questions.isNotEmpty ? questions[currentIndex] : null;
        shuffledAnswers = question?.getShuffledAnswers() ?? [];
        selectedAnswer = null;
        hasAnswered = false;
      }
    }
    setStateChange = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text("UnlockYour100"),
      ),
      body: Stack(
        children: [
          questions.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No questions available. Please activate an set with questionsin the library to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildQuestionCard(),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ...shuffledAnswers.map(
                                      (answer) => _buildAnswerCard(answer)),
                                  if (hasAnswered &&
                                      question?.explanation != "")
                                    _buildExplanationCard(
                                        question!.explanation),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              numberOfParticles: 8,
              emissionFrequency: 0,
              minBlastForce: 25,
              maxBlastForce: 50,
              particleDrag: 0.03,
              blastDirectionality: BlastDirectionality.explosive,
              gravity: 0.7,
              pauseEmissionOnLowFrameRate: true,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],

              confettiController: _confettiController,
            ),
          ),
        ],
      ),
      bottomNavigationBar: questions.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: FilledButton(
                onPressed: hasAnswered ? _handleNextQuestionPress : null,
                child: Text(
                  ((currentIndex != questions.length - 1) || !hasAnswered)
                      ? 'Next Question'
                      : 'Return to First Question',
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildQuestionCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final setProvider = Provider.of<SetProvider>(context);
    return Card.outlined(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: colorScheme.inverseSurface,
          width: 2,
        ),
      ),
      color: setProvider
          .getSetByName(question!.setName)
          .selectedColorKey
          .getColorFromScheme(Theme.of(context).colorScheme),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MixedText(
                text: question!.question,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20),
            const SizedBox(height: 8),
            Text(
              question!.setName,
              style: TextStyle(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${currentIndex + 1}/${questions.length}',
              style: TextStyle(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerCard(String text) {
    final colorScheme = Theme.of(context).colorScheme;

    final isCorrect = text == question!.correctAnswer;
    final isHighlighted =
        ((isCorrect && hasAnswered) || selectedAnswer == text);
    final isRelevant = isHighlighted || !hasAnswered;

    return AnimatedContainer(
      curve: Curves.easeInOut,
      height: isRelevant ? null : 0,
      margin: EdgeInsets.symmetric(vertical: (isRelevant) ? 8 : 0),
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? (isCorrect ? Colors.green.shade700 : Colors.red.shade800)
              : colorScheme.inverseSurface,
          width: isHighlighted ? 6 : 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => (hasAnswered) ? null : _handleAnswerPress(text),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MixedText(
              text: text,
              color: colorScheme.onSurface,
              fontWeight: null,
              fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.inverseSurface,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MixedText(
            text: text,
            color: colorScheme.onSurface,
            fontWeight: null,
            fontSize: 18),
      ),
    );
  }

  _handleAnswerPress(String text) {
    final setProvider = Provider.of<SetProvider>(context, listen: false);
    setState(() {
      setStateChange = true;
      selectedAnswer = text;
      hasAnswered = true;
    });
    if (text == question!.correctAnswer) {
      _confettiController.play();

      _audioPlayer.play(AssetSource('correct.mp3'));
      question!.correctAnswers = question!.correctAnswers + 1;
    } else {
      _audioPlayer.play(AssetSource('wrong.mp3'), volume: 0.7);
    }
    setProvider.updateQuestionSuccessRate(
        question!, text == question!.correctAnswer);
    question!.totalAnswers = question!.totalAnswers + 1;
  }

  _handleNextQuestionPress() {
    setState(() {
      setStateChange = true;
      if (currentIndex != questions.length - 1) {
        currentIndex = currentIndex + 1;
      } else {
        currentIndex = 0;
      }
      selectedAnswer = null;
      hasAnswered = false;
      question = questions[currentIndex];
      shuffledAnswers = question!.getShuffledAnswers();
    });
  }
}
