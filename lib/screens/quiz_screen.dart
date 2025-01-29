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
  late ConfettiController _controllerBottomCenter;
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
    final setProvider = Provider.of<SetProvider>(context);
    if (setStateChange == false) {
      List<Question> questions = _fetchActiveQuestions(setProvider);
      if (!areListsEqual(questions, this.questions)) {
        this.questions = questions;
        questions.shuffle();
        currentIndex = 0;
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
                      'No questions available. Please activate an existing set with questions or create a new one and add questions to it to continue.',
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
                                  ...shuffledAnswers
                                      .map((answer) => _buildAnswerCard(answer)),
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
              // make it blast down
              numberOfParticles: 5,
              emissionFrequency: 0.01,
              minBlastForce: 10,
              maxBlastForce: 50,
              blastDirectionality: BlastDirectionality.explosive,
              gravity: 1,
              pauseEmissionOnLowFrameRate: true,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
              confettiController: _controllerBottomCenter,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: FilledButton(
          onPressed: hasAnswered ? _handleNextQuestionPress : null,
          child: const Text(
            'Next Question',
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    final setProvider = Provider.of<SetProvider>(context);
    return Card.outlined(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: setProvider
              .getSetByName(question!.setName)
              .selectedColorKey
              .getBorderColorFromScheme(Theme.of(context).colorScheme),
          width: 1.0,
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
                color: setProvider
                    .getSetByName(question!.setName)
                    .selectedColorKey
                    .getTextColorFromScheme(Theme.of(context).colorScheme),
                fontWeight: FontWeight.bold,
                fontSize: 20),
            const SizedBox(height: 8),
            Text(
              question!.setName,
              style: TextStyle(
                fontSize: 14,
                color: setProvider
                    .getSetByName(question!.setName)
                    .selectedColorKey
                    .getTextColorFromScheme(Theme.of(context).colorScheme),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${currentIndex + 1}/${questions.length}',
              style: TextStyle(
                fontSize: 14,
                color: setProvider
                    .getSetByName(question!.setName)
                    .selectedColorKey
                    .getTextColorFromScheme(Theme.of(context).colorScheme),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? (isCorrect ? Colors.green.shade900 : Colors.red.shade900)
              : colorScheme.onSurface,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
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
    {
      setState(() {
        setStateChange = true;
        selectedAnswer = text;
        hasAnswered = true;
      });
      if (text == question!.correctAnswer) {
        _controllerBottomCenter.play();
        _audioPlayer.play(AssetSource('correct.mp3'));
        question!.correctAnswers = question!.correctAnswers + 1;
      }
      question!.totalAnswers = question!.totalAnswers + 1;
    }
  }

  _handleNextQuestionPress() {
    {
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
}
