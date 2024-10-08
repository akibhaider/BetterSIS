import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'generate_tips.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GraphicalResult extends StatefulWidget {
  final Map<String, dynamic> userData;

  const GraphicalResult({super.key, required this.userData});

  @override
  _GraphicalResultState createState() => _GraphicalResultState();
}

class _GraphicalResultState extends State<GraphicalResult> {
  List<double> semesterGPAs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSemesterGPAs();
  }

  Future<void> _fetchSemesterGPAs() async {
    try {
      QuerySnapshot semesterResults = await FirebaseFirestore.instance
          .collection('Results')
          .doc('Final')
          .collection(widget.userData['id'])
          .get();

      List<double> gpas = [];

      for (var doc in semesterResults.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        double gpa = data['gpa'] ?? 0.0;
        gpas.add(gpa);
      }

      setState(() {
        semesterGPAs = gpas;
        semesterGPAs.removeLast();
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching semester GPAs: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTips() {
    showDialog(
      context: context,
      builder: (context) {
        return GenerateTips(userData: widget.userData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        height: screenHeight * 0.5,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Semester-wise GPA Graph',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    height: screenHeight * 0.3,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: screenWidth * 0.08,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: screenHeight * 0.08,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 == 0) {
                                  return Text(value.toInt().toString());
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        maxY: 4,
                        minY: 0,
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            spots: semesterGPAs
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                      e.key.toDouble() + 1,
                                      e.value,
                                    ))
                                .toList(),
                            barWidth: 5,
                            belowBarData: BarAreaData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //SizedBox(height: screenHeight * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      _showTips();
                    },
                    child: Text(
                      'How do I Improve?',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
