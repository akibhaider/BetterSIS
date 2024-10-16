import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DetailedSemesterResult extends StatefulWidget {
  final String userId;
  final String semesterID;
  final String userDept;

  const DetailedSemesterResult(
      {super.key,
      required this.userId,
      required this.semesterID,
      required this.userDept});

  @override
  State<DetailedSemesterResult> createState() => _DetailedSemesterResultState();
}

class _DetailedSemesterResultState extends State<DetailedSemesterResult> {
  Map<String, List<Map<String, dynamic>>> departmentCourseMarks = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSemesterResult();
  }

  Future<void> _fetchSemesterResult() async {
    try {
      QuerySnapshot courseResults = await FirebaseFirestore.instance
          .collection('Results')
          .doc('Final')
          .collection(widget.userId)
          .doc(widget.semesterID)
          .collection('Courses')
          .get();

      if (courseResults.docs.isNotEmpty) {
        Map<String, List<Map<String, dynamic>>> tempDepartmentMap = {};

        for (var doc in courseResults.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String courseCode = doc.id;

          Map<String, dynamic> marks = data['marks'] ?? {};

          int attendanceMark = marks['attendance'] ?? 0;
          int finalMark = marks['final'] ?? 0;
          int midMark = marks['mid'] ?? 0;
          int quizMark = marks['quiz'] ?? 0;

          Map<String, String?> courseDetails =
              await _fetchCourseName(courseCode);

          String courseDept = courseCode.split('-')[0];

          if (!tempDepartmentMap.containsKey(courseDept)) {
            tempDepartmentMap[courseDept] = [];
          }

          tempDepartmentMap[courseDept]?.add({
            'courseCode': courseCode,
            'courseName': courseDetails['courseName'],
            'shortName': courseDetails['shortName'],
            'attendance': attendanceMark,
            'final': finalMark,
            'mid': midMark,
            'quiz': quizMark,
          });
        }

        setState(() {
          departmentCourseMarks = tempDepartmentMap;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching semester results: $error');
    }
  }

  Future<Map<String, String?>> _fetchCourseName(String courseID) async {
    try {
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(widget.userDept)
          .collection(widget.semesterID)
          .doc(courseID)
          .get();

      if (courseDoc.exists) {
        Map<String, dynamic>? data = courseDoc.data() as Map<String, dynamic>?;

        String? courseName = data?['name'];
        String? shortName = data?['short'];

        return {
          'courseName': courseName ?? 'Unknown Course',
          'shortName': shortName ?? 'Unknown Short Name'
        };
      } else {
        return {
          'courseName': 'Course not found',
          'shortName': 'Short name not found',
        };
      }
    } catch (error) {
      print('Error fetching course name: $error');
      return {
        'courseName': 'Error fetching course',
        'shortName': 'Error fetching short name',
      };
    }
  }

  Widget _buildBarChart(List<Map<String, dynamic>> courses, double maxHeight) {
    return SizedBox(
      height: maxHeight,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: 100,
          barGroups: courses.map((course) {
            double totalMarks = (course['attendance'] +
                    course['quiz'] +
                    course['mid'] +
                    course['final'])
                .toDouble();

            return BarChartGroupData(
              x: courses.indexOf(course),
              barRods: [
                BarChartRodData(
                  toY: totalMarks,
                  color: AppTheme.getTheme(course['courseCode'].split('-')[0])
                      .primaryColor,
                  width: 20,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String shortName = courses[value.toInt()]['shortName'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      shortName,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey, width: 1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Semester Results',
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detailed Results for Semester ${widget.semesterID}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: departmentCourseMarks.length,
                    itemBuilder: (context, index) {
                      String dept = departmentCourseMarks.keys.elementAt(index);
                      List<Map<String, dynamic>> courses =
                          departmentCourseMarks[dept]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Department: $dept',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Table(
                            border: TableBorder.all(),
                            columnWidths: isSmallScreen
                                ? {
                                    0: const FlexColumnWidth(2),
                                    1: const FlexColumnWidth(1),
                                  }
                                : {
                                    0: const FlexColumnWidth(3),
                                    1: const FlexColumnWidth(2),
                                  },
                            children: [
                              const TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Course Name',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Marks',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ]),
                              for (var course in courses)
                                TableRow(children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                        isSmallScreen ? 4.0 : 8.0),
                                    child: Text(course['courseName']),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(
                                        isSmallScreen ? 4.0 : 8.0),
                                    child: Text(
                                      (course['attendance'] +
                                              course['quiz'] +
                                              course['mid'] +
                                              course['final'])
                                          .toString(),
                                    ),
                                  ),
                                ])
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Marks Distribution for $dept Courses',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: screenHeight * 0.3,
                            child: _buildBarChart(courses, screenHeight * 0.3),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
