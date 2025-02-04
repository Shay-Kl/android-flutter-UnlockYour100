import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../providers/set_provider.dart';
import '../models/set.dart';
import 'dart:math';
import '../models/question.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Today Card
          _buildTodayCard(context),
          const ReviewCard(),
          const SuccessRateCard(),
          //_buildSuccessRateCard(context),
        ],
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activityProvider = Provider.of<ActivityProvider>(context, listen:false);
    final answered = activityProvider.answeredQuestionsPerDay;
    final correct = activityProvider.answeredCorrectlyPerDay;
    final answeredToday = answered.isNotEmpty ? answered.last : 0;
    final correctToday = correct.isNotEmpty ? correct.last : 0;
    final successRate = (answeredToday == 0) ? 0 : (correctToday / answeredToday * 100);
    return Card.outlined(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.inverseSurface,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today’s Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(thickness: 1, color: Colors.grey),
              _buildInfoRow('Questions Answered:', answeredToday.toString()),
              _buildInfoRow('Correctly Answered:', correctToday.toString()),
              _buildInfoRow('Success Rate:', '${successRate.toStringAsFixed(2)}%'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

}

class ReviewCard extends StatefulWidget{
    const ReviewCard({super.key});

    @override
    State<ReviewCard> createState() => _ReviewCardState();  
}

class _ReviewCardState extends State<ReviewCard>{
  final timeRanges = ['week', 'month', 'all-time'];
  String selectedTimeRange = 'week';
  List<int> answered = [];
  List<int> answeredCorrectly = [];

  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;
    final activityProvider = Provider.of<ActivityProvider>(context);
    final totalAnswered = activityProvider.answeredQuestionsPerDay;
    final totalCorrect = activityProvider.answeredCorrectlyPerDay;
    answered = [0];
    answeredCorrectly = [0];
    if (selectedTimeRange == 'week'){
      if (totalAnswered.length >= 7) {
        answered = totalAnswered.sublist(totalAnswered.length - 7);
        answeredCorrectly = totalCorrect.sublist(totalCorrect.length - 7);
      }
      else {
        answered = List<int>.filled(7 - totalAnswered.length, 0) + totalAnswered;
        answeredCorrectly = List<int>.filled(7 - totalCorrect.length, 0) + totalCorrect;
      }
    } else if (selectedTimeRange == 'month'){
      if (totalAnswered.length >= 31) {
        answered = totalAnswered.sublist(totalAnswered.length - 31);
        answeredCorrectly = totalCorrect.sublist(totalCorrect.length - 31);
      }
      else {
        answered = List<int>.filled(31 - totalAnswered.length, 0) + totalAnswered;
        answeredCorrectly = List<int>.filled(31 - totalCorrect.length, 0) + totalCorrect;
      }
    } else {
        answered = totalAnswered;
        answeredCorrectly = totalCorrect;
    }
    final totalQuestionAnswered = (answered.isNotEmpty) ? answered.reduce((value, element) => value + element) : 0;
    final totalDaysStudied = (answered.isNotEmpty) ? answered.where((element) => element > 0).length : 0;
    final averageQuestionsPerDayStudied = totalDaysStudied != 0 ? totalQuestionAnswered / totalDaysStudied : 0;
    final totalCorrectlyAnswered = (answeredCorrectly.isNotEmpty) ? answeredCorrectly.reduce((value, element) => value + element): 0;
    final averageQuestionPerEachDay = answered.isNotEmpty ? totalQuestionAnswered / answered.length : 0;
    return Card.outlined(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.inverseSurface,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  //color: Colors.blueGrey,
                ),
              ),
              const Divider(thickness: 1, color: Colors.grey),
              Row(
                children: [
                  const Text(
                    'Time range:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  const Spacer(),
                  ToggleButtons(
                    isSelected: timeRanges.map((range) => range == selectedTimeRange).toList(),
                    onPressed: (int index) {
                      setState(() {
                        selectedTimeRange = timeRanges[index];
                      });
                    },
                    borderRadius: BorderRadius.circular(12), // Rounded corners for toggle
                    //color: Colors.black54,
                    selectedColor: Colors.blueAccent,
                    children: timeRanges.map((range) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(range),
                      )
                    ).toList(),
                    //borderColor: Colors.black26,
                    //fillColor: Colors.blue.withValues(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Activity Chart
              if (answered.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      maxY: _calculateMaxY(answered),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: max(1, _calculateMaxY(answered) / 5),
                            getTitlesWidget: (value, _) => Text(value.toInt().toString()),
                          ),
                        ),
                        // bottomTitles: AxisTitles(
                        //   sideTitles: SideTitles(
                        //     showTitles: true,
                        //     reservedSize: 32,
                        //     interval: answered.length > 7 ? (answered.length / 7).floor().toDouble() : 1,
                        //     getTitlesWidget: (value, _) {
                        //       final index = value.toInt();
                        //       final titlesPerGroup = (answered.length / (answered.length > 7 ? 7 : answered.length)).ceil();
                        //       if (index >= 0 && index < answered.length && index % titlesPerGroup == 0) {
                        //         return Padding(
                        //           padding: const EdgeInsets.symmetric(vertical: 8), // Add padding for better spacing
                        //           child: Text(
                        //             'Day ${(index + 1)}',
                        //             style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),  // You can adjust font size for readability
                        //           ),
                        //         );
                        //       }  else {
                        //         return const SizedBox.shrink();
                        //       }
                        //     },
                        //   ),
                        // ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        drawHorizontalLine: true,
                      ),
                      barGroups: List.generate(answered.length, (index) {
                        int correct = answeredCorrectly[index];
                        int incorrect = answered[index] - correct;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: correct.toDouble() + incorrect.toDouble(),
                              rodStackItems: [
                                BarChartRodStackItem(0, correct.toDouble(), Colors.green),
                                BarChartRodStackItem(correct.toDouble(), correct.toDouble() + incorrect.toDouble(), Colors.red),
                              ],
                              width: 100 / answered.length,
                              borderRadius: BorderRadius.zero,
                              //color: Colors.green,
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                  duration: const Duration(milliseconds: 0),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem(Colors.green, "Correct Answers"),
                    const SizedBox(width: 16),
                    _buildLegendItem(Colors.red, "Incorrect Answers"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Total Questions Answered:', totalQuestionAnswered.toString()),
              _buildInfoRow('Total Days Studied:', totalDaysStudied.toString()),
              _buildInfoRow('Average Questions per Day in Range', averageQuestionPerEachDay.toStringAsFixed(2)),
              _buildInfoRow('Average Questions per Study Day', averageQuestionsPerDayStudied.toStringAsFixed(2)),
              _buildInfoRow('Total Correctly Answered:', totalCorrectlyAnswered.toString()),
            ],
          ),
        ),
      )
    );
  }
  
  double _calculateMaxY(List<int> data) {
      final maxData = (data.isNotEmpty) ? data.reduce(max) : 10;
      return maxData * 1.1;
  }
}

class SuccessRateCard extends StatefulWidget {
  const SuccessRateCard({super.key});

  @override
  State<SuccessRateCard> createState() => _SuccessRateCardState();
}

class _SuccessRateCardState extends State<SuccessRateCard> {
  final options = ['All', 'Active', 'Choose one'];
  String selectedOption = 'All';
  bool isOptionSelected = true;
  List<QuestionSet> allSets = [];
  List<Question> selectedQuestions = [];
  String selectedSet = '';
  //String setFilter = 'Choose a set'; // Example list

  @override 
  void initState() {
    super.initState();
    final setProvider = Provider.of<SetProvider>(context, listen: false);
    allSets = setProvider.sets;
    final List<Question> questions = [];
    for (final set in allSets) {
      questions.addAll(set.questions);
    }
    selectedQuestions = questions;
    debugPrint('DEBUG: Selected questions size: ${selectedQuestions.length}');
    isOptionSelected = true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final setProvider = Provider.of<SetProvider>(context);
    allSets = setProvider.sets;
    if (selectedOption == 'All') {
      final List<Question> questions = [];
      for (final set in allSets) {
        questions.addAll(set.questions);
      }
      selectedQuestions = questions;
      isOptionSelected = true;
    }
    else if (selectedOption == 'Active') {
      if (allSets.isEmpty) {
        selectedQuestions = [];
        isOptionSelected = false;
      }
      else {
        final activeSets = (allSets.isNotEmpty) ? allSets.where((set) => set.isActive).toList() : [];
        // Combine questions from all active sets
        final List<Question> activeQuestions = [];
        for (final set in activeSets) {
          activeQuestions.addAll(set.questions);
        }
        selectedQuestions = activeQuestions;
        isOptionSelected = true;
      }
    }
    else {
      if (selectedSet.isNotEmpty) {
        if (allSets.isEmpty) {
          selectedQuestions = [];
          isOptionSelected = false;
        }
        else {
          selectedQuestions = (allSets.isNotEmpty) ? allSets.firstWhere((set) => set.setName == selectedSet).questions : [];
          isOptionSelected = true;
        }
        
      }
      else {
        isOptionSelected = false;
      }
    }
    final totalQuestion = selectedQuestions.length;
    final totalQuestionAnswered = (selectedQuestions.isNotEmpty) ? selectedQuestions.where((question) => question.totalAnswers > 0).length : 0;
    double successRateSum = selectedQuestions
    .map((question) => question.successRate)
    .fold(0.0, (a, b) => a + b);
    double result = 100 * successRateSum;
    final totalSuccessRate = totalQuestionAnswered > 0 ? result / totalQuestionAnswered : 0;

    return Consumer<SetProvider>(
      builder: (context, setProvider, child) {
        allSets = setProvider.sets;
        final allSetNames = allSets.map((set) => set.setName).toList();
        if (allSets.isEmpty) { 
          return Card.outlined(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.inverseSurface,
                  width: 2,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Success Rate Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(thickness: 1, color: Colors.grey),
                    Text('No sets available'),
                  ],
                ),
              ),
            ),
          );
        }
        else {
          return Card.outlined(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.inverseSurface,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Success Rate Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        //color: Colors.blueGrey,
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                    Row(
                      children: [
                        const Text(
                          'Options:',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        const Spacer(),
                        ToggleButtons(
                          isSelected: options.map((range) => range == selectedOption).toList(),
                          onPressed: (int index) {
                            setState(() {
                              selectedOption = options[index];
                              if (selectedOption == 'All') {
                                final List<Question> questions = [];
                                for (final set in allSets) {
                                  questions.addAll(set.questions);
                                }
                                selectedQuestions = questions;
                                isOptionSelected = true;
                              }
                              else if (selectedOption == 'Active') {
                                final activeSets = (allSets.isNotEmpty) ? allSets.where((set) => set.isActive).toList() : [];
                                // Combine questions from all active sets
                                final List<Question> activeQuestions = [];
                                for (final set in activeSets) {
                                  activeQuestions.addAll(set.questions);
                                }
                                selectedQuestions = activeQuestions;
                                isOptionSelected = true;
                              }
                              else {
                                isOptionSelected = false;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12), // Rounded corners for toggle
                          //color: Colors.black54,
                          selectedColor: Colors.blueAccent,
                          children: options.map((range) => 
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(range),
                            )
                          ).toList(),
                          //borderColor: Colors.black26,
                          //fillColor: Colors.blue.withValues(),
                        ),
                      ],
                    ),
                    Center(
                    child: DropdownButton<String>(
                      value: selectedSet.isNotEmpty ? selectedSet : allSetNames[0],
                      hint: const Text('Select a Set'),
                      items: allSetNames.map((set) {
                        return DropdownMenuItem(value: set, child: Text(set));
                      }).toList(),
                      isExpanded: true,
                      onChanged: selectedOption != 'Choose one' 
                        ? null  // Disable the dropdown
                        : (value) {
                        setState(() {
                          selectedSet = value!;
                          selectedQuestions = allSets.firstWhere((set) => set.setName == selectedSet).questions;
                          isOptionSelected = true;
                        });
                      },
                      disabledHint: const Text('Select a Set (disabled)'),
                      style: TextStyle(
                        color: (selectedOption != 'Choose one') ? Colors.black : Colors.grey, // Change the color to indicate it’s disabled
                      ),
                    )),
                    // Activity Chart
                    if (isOptionSelected && selectedQuestions.isNotEmpty) 
                      Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: showingSections(selectedQuestions),
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: List.generate(5, (index) {
                              return _buildLegendItem(getColor(index), getLabel(index));
                            }),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Total Questions Selected:', totalQuestion.toString()),
                          _buildInfoRow('Total Questions Ever Answered:', totalQuestionAnswered.toString()),
                          _buildInfoRow('Average Success Rate:', totalSuccessRate.toStringAsFixed(2), additional: '%'),
                        ],
                        
                      )
                    else if (!isOptionSelected) 
                      const SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            'Choose a set',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      else 
                      const SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            'No questions available',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            ));
          }
        }
      );
  }

  Color getColor(int index) {
    const colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  String getLabel(int index) {
    const labels = [
      'Never answered',
      'Success rate of 0-25%',
      'Success rate of  25-49%',
      'Success rate of 50-74%',
      'Success rate of 74-100%',
    ];
    return labels[index % labels.length];
  }

  List<PieChartSectionData> showingSections(List<Question> questions) {
    List<int> bins = createBins(questions);

    return List.generate(bins.length, (i) {
      //final isTouched = i == 0; // You can adjust the touched logic
      //final fontSize = isTouched ? 25.0 : 16.0;
      //final radius = isTouched ? 60.0 : 50.0;
      const fontSize = 16.0;
      const radius = 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: getColor(i),
        value: bins[i].toDouble(),
        title: '${bins[i]}',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
 
  List<int> createBins(List<Question> questions) {
  List<int> bins = [0, 0, 0, 0, 0];
  for (var question in questions) {
      double rate = (question.successRate > 1) ? 1 : question.successRate;
      if (question.totalAnswers == 0) {
        bins[0]++;
      } else
      if (rate < 0.25) {
        bins[1]++;
      } else if (rate < 0.5) {
        bins[2]++;
      } else if (rate < 0.75) {
        bins[3]++;
      } else if (rate <= 1){
        bins[4]++;
      }
  }
  return bins;
} 

}

Widget _buildLegendItem(Color color, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
        ),
      ),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 14)),
    ],
  );
}

  Widget _buildInfoRow(String title, String value, {String additional = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value + additional,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }