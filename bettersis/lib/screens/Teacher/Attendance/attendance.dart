import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // To format date

class Attendance extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;
  const Attendance({super.key, required this.onLogout, required this.userData});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  DateTime _selectedDate = DateTime.now();
  String? selectedCourse;
  String? selectedSection;
  List<Map<String, dynamic>> students = [];
  List<String> presentStudents = [];
  bool isLoading = false;
  bool attendanceTaken =
      false; // New field to track if attendance is already taken

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: "Attendance",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendar(),
            const SizedBox(height: 10),
            _buildCourseAndSectionSelection(),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildStudentList(screenWidth),
            if (students.isNotEmpty &&
                !attendanceTaken) // Show submit button only if attendance not taken
              ElevatedButton(
                onPressed: _submitAttendance,
                child: const Text('Submit Attendance'),
              ),
          ],
        ),
      ),
    );
  }

  // Build Calendar
  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _selectedDate,
      firstDay: DateTime.utc(2000, 10, 16),
      lastDay: DateTime.utc(2030, 10, 16),
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });
      },
    );
  }

  // Build Course and Section dropdown
  Widget _buildCourseAndSectionSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          DropdownButton<String>(
            hint: const Text("Select Course"),
            value: selectedCourse,
            items: widget.userData['courses']
                .map<DropdownMenuItem<String>>((course) {
              return DropdownMenuItem<String>(
                value: course,
                child: Text(course),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCourse = value;
                selectedSection = null;
                students.clear();
              });
            },
          ),
          if (selectedCourse != null)
            DropdownButton<String>(
              hint: const Text("Select Section"),
              value: selectedSection,
              items: ['1', '2'].map<DropdownMenuItem<String>>((section) {
                return DropdownMenuItem<String>(
                  value: section,
                  child: Text(section),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSection = value;
                  _fetchStudents();
                });
              },
            ),
        ],
      ),
    );
  }

  Future<void> _fetchStudents() async {
    if (selectedCourse == null || selectedSection == null) return;

    setState(() {
      isLoading = true;
      attendanceTaken = false;
    });

    try {
      // Fetch the last three attendance records for the selected course and section
      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection('Attendance')
          .doc(selectedCourse)
          .collection('Sections')
          .doc(selectedSection)
          .collection('Attendance')
          .limit(3) // Limit to the last three records
          .get();

      Map<String, List<bool>> studentAttendanceStatus = {};

      // Initialize attendance status for each student for 3 days
      for (var doc in attendanceSnapshot.docs) {
        List<dynamic> present = doc['present'] ?? [];
        List<dynamic> absent = doc['absent'] ?? [];

        // Mark students who were present
        for (var studentId in present) {
          if (!studentAttendanceStatus.containsKey(studentId)) {
            studentAttendanceStatus[studentId] = [true];
          } else {
            studentAttendanceStatus[studentId]!.add(true);
          }
        }

        // Mark students who were absent
        for (var studentId in absent) {
          if (!studentAttendanceStatus.containsKey(studentId)) {
            studentAttendanceStatus[studentId] = [false];
          } else {
            studentAttendanceStatus[studentId]!.add(false);
          }
        }
      }

      // Fetch student data for those enrolled in this course and section
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('courses')
          .collection('Enrolled')
          .doc(selectedCourse)
          .get();

      if (courseDoc.exists) {
        List<dynamic> enrolledStudentIds = courseDoc['students'] ?? [];

        QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('id', whereIn: enrolledStudentIds)
            .where('section', isEqualTo: selectedSection)
            .get();

        List<Map<String, dynamic>> studentList = [];
        for (var studentDoc in studentSnapshot.docs) {
          var data = studentDoc.data() as Map<String, dynamic>;
          String studentId = data['id'];
          List<bool> previousAttendance =
              studentAttendanceStatus[studentId] ?? [false, false, false];

          if (previousAttendance.length < 3) {
            previousAttendance =
                List<bool>.filled(3 - previousAttendance.length, false) +
                    previousAttendance;
          }

          studentList.add({
            'name': data['name'],
            'id': data['id'],
            'previousAttendance': previousAttendance, 
          });
        }

        studentList
            .sort((a, b) => int.parse(a['id']).compareTo(int.parse(b['id'])));

        setState(() {
          students = studentList;
          presentStudents.clear();
          isLoading = false;
        });
      } else {
        setState(() {
          students = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching students: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Build the student list with checkboxes and last 3 days' attendance
  Widget _buildStudentList(double screenWidth) {
    double fontSize = screenWidth * 0.045;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        var student = students[index];
        bool isPresent = presentStudents.contains(student['id']);
        List<bool> previousAttendance =
            student['previousAttendance'] ?? [false, false, false];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: TextStyle(
                            fontSize: fontSize, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'ID: ${student['id']}',
                        style: TextStyle(
                          fontSize: fontSize * 0.85,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildAttendanceCircle(
                              previousAttendance[0]), // 3 days ago
                          const SizedBox(width: 5),
                          _buildAttendanceCircle(
                              previousAttendance[1]), // 2 days ago
                          const SizedBox(width: 5),
                          _buildAttendanceCircle(
                              previousAttendance[2]), // 1 day ago
                        ],
                      )
                    ],
                  ),
                ),
                if (!attendanceTaken)
                  Checkbox(
                    value: isPresent,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          presentStudents.add(student['id']);
                        } else {
                          presentStudents.remove(student['id']);
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceCircle(bool isPresent) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPresent
            ? Colors.green
            : Colors.red,
      ),
    );
  }

  // Submit the attendance
  Future<void> _submitAttendance() async {
    try {
      String formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
      DocumentReference attendanceDoc = FirebaseFirestore.instance
          .collection('Attendance')
          .doc(selectedCourse)
          .collection('Sections')
          .doc(selectedSection)
          .collection('Attendance')
          .doc(formattedDate);

      await attendanceDoc.set({
        'present': presentStudents,
        'absent': students
            .where((student) => !presentStudents.contains(student['id']))
            .map((student) => student['id'])
            .toList(),
        'taken': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance submitted successfully')),
      );
    } catch (e) {
      print('Error submitting attendance: $e');
    }
  }
}
