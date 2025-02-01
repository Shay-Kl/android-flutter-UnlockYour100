import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
//import '../providers/set_provider.dart';
import '../models/set.dart';
import 'dart:math';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('User Activity Stats')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Today Card
          const SizedBox(height: 10),
          _buildTodayCard(context),
          const SizedBox(height: 10),
          const ReviewCard(),
          const SizedBox(height: 10),
          //_buildSuccessRateCard(context),
        ],
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context) {
  final activityProvider = Provider.of<ActivityProvider>(context, listen:false);
  final answered = activityProvider.answeredQuestionsPerDay;
  final correct = activityProvider.answeredCorrectlyPerDay;
  final answeredToday = answered.isNotEmpty ? answered.last : 0;
  final correctToday = correct.isNotEmpty ? correct.last : 0;
  final successRate = (answeredToday == 0) ? 0 : (correctToday / answeredToday * 100);
  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.all(16),
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
          const Divider(),
          _buildInfoRow('Questions Answered:', answeredToday.toString()),
          _buildInfoRow('Correctly Answered:', correctToday.toString()),
          _buildInfoRow('Success Rate:', '${successRate.toStringAsFixed(2)}%'),
        ],
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


  Widget _buildSuccessRateCard(BuildContext context) {
    return const Card(
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            title: Text('Success Rate'),
          ),
          ListTile(
            title: Text('Success Rate Distribution'),
            trailing: Text('add'),
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
        final activityProvider = Provider.of<ActivityProvider>(context);
        final totalAnswered = activityProvider.answeredQuestionsPerDay;
        final totalCorrect = activityProvider.answeredCorrectlyPerDay;

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
        final totalQuestionAnswered = answered.reduce((value, element) => value + element);
        final totalDaysStudied = answered.where((element) => element > 0).length;
        //final averageQuestionsPerDayStudied = totalDaysStudied != 0 ? totalQuestionAnswered / totalDaysStudied : 0;
        final totalCorrectlyAnswered = answeredCorrectly.reduce((value, element) => value + element);
        final averageQuestionPerEachDay = answered.isNotEmpty ? totalQuestionAnswered / answered.length : 0;
        return Card(
            elevation:8,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review Summary',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      //color: Colors.blueGrey,
                    ),
                  ),
                  const Divider(),
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
                        children: timeRanges.map((range) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(range),
                        )).toList(),
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
                        interval: max(1, _calculateMaxY(answered) / 5),
                        getTitlesWidget: (value, _) => Text(value.toInt().toString()),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: answered.length > 7 ? (answered.length / 7).floor().toDouble() : 1,
                        getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        final titlesPerGroup = (answered.length / (answered.length > 7 ? 7 : answered.length)).ceil();
                        if (index >= 0 && index < answered.length && index % titlesPerGroup == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8), // Add padding for better spacing
                            child: Text(
                              'Day ${(index + 1)}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),  // You can adjust font size for readability
                            ),
                          );
                        }  else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
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
                          toY: correct.toDouble(),
                          width: 1,
                          color: Colors.green,
                        ),
                        BarChartRodData(
                          toY: incorrect.toDouble(),
                          width: 1,
                          color: Colors.red,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
          _buildInfoRow('Total Questions Answered:', totalQuestionAnswered.toString()),
          _buildInfoRow('Total Days Studied:', totalDaysStudied.toString()),
          _buildInfoRow('Average Questions per Day in range', averageQuestionPerEachDay.toStringAsFixed(2)),
          _buildInfoRow('Total Correctly Answered:', totalCorrectlyAnswered.toString()),
        ],
      ),
    ));
  }
    double _calculateMaxY(List<int> data) {
        final maxData = data.reduce(max);
        return maxData * 1.1;
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

List<int> getSuccessRateData(List<QuestionSet> sets) {
    // Initialize counters for different success rate ranges
    final successRanges = List<int>.filled(10, 0); // 10 ranges: [0-0.1], [0.1-0.2], ..., [0.9-1.0]

    for (var set in sets) {
      for (var question in set.questions) {
        final successRate = question.correctAnswers / question.totalAnswers;
        if (successRate >= 0 && successRate < 0.1) {
          successRanges[0]++;
        } else if (successRate >= 0.1 && successRate < 0.2) {
          successRanges[1]++;
        } else if (successRate >= 0.2 && successRate < 0.3) {
          successRanges[2]++;
        } else if (successRate >= 0.3 && successRate < 0.4) {
          successRanges[3]++;
        } else if (successRate >= 0.4 && successRate < 0.5) {
          successRanges[4]++;
        } else if (successRate >= 0.5 && successRate < 0.6) {
          successRanges[5]++;
        } else if (successRate >= 0.6 && successRate < 0.7) {
          successRanges[6]++;
        } else if (successRate >= 0.7 && successRate < 0.8) {
          successRanges[7]++;
        } else if (successRate >= 0.8 && successRate < 0.9) {
          successRanges[8]++;
        } else if (successRate >= 0.9 && successRate <= 1.0) {
          successRanges[9]++;
        }
      }
    }
    return successRanges;
  }

