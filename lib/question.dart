class Question {
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;
  List<String> get answers => [correctAnswer, ...wrongAnswers]; //
  const Question(this.question, this.correctAnswer, this.wrongAnswers);
}