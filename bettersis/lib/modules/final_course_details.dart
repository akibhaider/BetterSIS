import 'package:bettersis/utis/themes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FinalCourseDetails extends StatelessWidget {
  final Map<String, dynamic> result;
  final String course;
  final String userDept;
  late double totalMarks;

  FinalCourseDetails(
      {Key? key,
      required this.result,
      required this.course,
      required this.userDept})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Detailed Result of',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            course,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 250,
            child: _buildBarChart(),
          ),
          const SizedBox(height: 30),
          _buildDetailsTable(),
          const SizedBox(height: 30),
          _displayGrade(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    double finalMarks = (result['marks']['final'] ?? 0.0).toDouble();
    double midMarks = (result['marks']['mid'] ?? 0.0).toDouble();
    double attendanceMarks = (result['marks']['attendance'] ?? 0.0).toDouble();
    double quizMarks = (result['marks']['quiz'] ?? 0.0).toDouble();

    totalMarks = finalMarks + midMarks + attendanceMarks + quizMarks;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('Final');
                  case 1:
                    return const Text('Mid');
                  case 2:
                    return const Text('Att.');
                  case 3:
                    return const Text('Quiz');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          // leftTitles: AxisTitles(
          //   sideTitles: SideTitles(
          //     showTitles: true,
          //     getTitlesWidget: (value, meta) {
          //       return Text('${value.toInt()}%');
          //     },
          //   ),
          // ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        barGroups: [
          _createBarGroup(0, finalMarks / 50 * 100),
          _createBarGroup(1, midMarks / 25 * 100),
          _createBarGroup(2, attendanceMarks / 5 * 100),
          _createBarGroup(3, quizMarks / 20 * 100),
        ],
      ),
    );
  }

  BarChartGroupData _createBarGroup(int x, double achieved) {
    ThemeData theme = AppTheme.getTheme(userDept);
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: achieved,
          color: theme.primaryColor,
          width: 20,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _displayGrade() {
    String grade;

    if (totalMarks >= 80 && totalMarks <= 100) {
      grade = 'A+';
    } else if (totalMarks >= 70 && totalMarks < 80) {
      grade = 'A';
    } else if (totalMarks >= 60 && totalMarks < 70) {
      grade = 'A-';
    } else if (totalMarks >= 55 && totalMarks < 60) {
      grade = 'B+';
    } else if (totalMarks >= 50 && totalMarks < 55) {
      grade = 'B';
    } else if (totalMarks >= 45 && totalMarks < 50) {
      grade = 'B-';
    } else if (totalMarks >= 40 && totalMarks < 45) {
      grade = 'C';
    } else if (totalMarks >= 33 && totalMarks < 40) {
      grade = 'D';
    } else {
      grade = 'F';
    }

    return Center(
      child: Text(
        'Grade: $grade',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailsTable() {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      border: TableBorder.all(
        color: Colors.black, 
        width: 1.5, 
      ),
      children: [
        _buildTableRow('Mid', result['marks']['mid'], 25),
        _buildTableRow('Attendance', result['marks']['attendance'], 5),
        _buildTableRow('Quiz', result['marks']['quiz'], 20),
        _buildTableRow('Final', result['marks']['final'], 50),
      ],
    );
  }

  TableRow _buildTableRow(String label, dynamic achievedMarks, int totalMarks) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              '${achievedMarks ?? 'N/A'} / $totalMarks',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
