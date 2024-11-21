import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const Attendance({super.key, required this.onLogout, required this.userData});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  String? selectedCourse;
  List<String> enrolledCourses = [];
  Map<String, dynamic> attendanceData = {};
  List<String> absentDates = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
    setState(() {
      isLoading = true;
    });

    try {
      String userId = widget.userData['id'];
      String semesterNumber = widget.userData['semester'][0];

      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: userId)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = usersSnapshot.docs.first;

        DocumentSnapshot enrolledCoursesSnapshot = await FirebaseFirestore
            .instance
            .collection('Users')
            .doc(userDoc.id)
            .collection('Enrolled Courses')
            .doc(semesterNumber)
            .get();

        if (enrolledCoursesSnapshot.exists) {
          QuerySnapshot courseListSnapshot = await enrolledCoursesSnapshot
              .reference
              .collection('Course List')
              .get();

          List<String> courses =
              courseListSnapshot.docs.map((doc) => doc.id).toList();

          setState(() {
            enrolledCourses = courses;
          });
        } else {
          print('No enrolled courses found for this semester.');
        }
      } else {
        print('No user found with the given userId.');
      }
    } catch (e) {
      print('Error fetching enrolled courses: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchAttendanceData(String courseCode) async {
    setState(() {
      isLoading = true;
      attendanceData = {};
      absentDates = [];
    });

    try {
      QuerySnapshot dateDocsSnapshot = await FirebaseFirestore.instance
          .collection('Attendance')
          .doc(courseCode)
          .collection('Sections')
          .doc(widget.userData['section'])
          .collection('Attendance')
          .get();

      int totalClasses = dateDocsSnapshot.docs.length;
      int presentClasses = 0;
      List<String> absentDatesTemp = [];

      for (var doc in dateDocsSnapshot.docs) {
        Map<String, dynamic> dateData = doc.data() as Map<String, dynamic>;

        if (dateData['present'] != null &&
            (dateData['present'] as List).contains(widget.userData['id'])) {
          presentClasses++;
        } else {
          absentDatesTemp.add(doc.id); // Add the date to absent dates
        }
      }

      setState(() {
        attendanceData = {
          'totalClasses': totalClasses,
          'presentClasses': presentClasses,
        };
        absentDates = absentDatesTemp;
      });
    } catch (e) {
      print('Error fetching attendance: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  String _calculateAttendanceMarks() {
    if (attendanceData.isEmpty) return 'No attendance data available';

    int totalClasses = attendanceData['totalClasses'] ?? 0;
    int presentClasses = attendanceData['presentClasses'] ?? 0;

    if (totalClasses == 0) return 'No attendance data available';

    double percentage = (presentClasses / totalClasses) * 100;
    int marks;

    if (percentage >= 95) {
      marks = 30;
    } else if (percentage >= 90) {
      marks = 24;
    } else if (percentage >= 85) {
      marks = 18;
    } else if (percentage >= 80) {
      marks = 12;
    } else {
      marks = 0;
    }

    return 'Attendance: $presentClasses / $totalClasses\n'
        'Percentage: ${percentage.toStringAsFixed(2)}%\n'
        'Attendance Marks: $marks';
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: "Attendance",
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Half
                Container(
                  color: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.userData['name'],
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.userData['id'],
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: screenWidth *
                              0.75, // Set width to 75% of the screen
                          child: DropdownButton<String>(
                            hint: const Text(
                              'Select a course',
                              style: TextStyle(color: Colors.white),
                            ),
                            value: selectedCourse,
                            underline: const SizedBox(),
                            items: enrolledCourses
                                .map<DropdownMenuItem<String>>((course) {
                              return DropdownMenuItem<String>(
                                value: course,
                                child: Text(
                                  course,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 46, 45, 45),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCourse = value;
                                _fetchAttendanceData(value!);
                              });
                            },
                            isExpanded: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Half
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          selectedCourse == null
                              ? 'Choose a course first'
                              : selectedCourse!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.075,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (selectedCourse != null) ...[
                          Text(
                            _calculateAttendanceMarks(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Absent Dates:',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: absentDates.length,
                              itemBuilder: (context, index) {
                                return Text(
                                  absentDates[index],
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
