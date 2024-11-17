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
      String formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
      DocumentReference attendanceDoc = FirebaseFirestore.instance
          .collection('Attendance')
          .doc(selectedCourse)
          .collection('Sections')
          .doc(selectedSection)
          .collection('Attendance')
          .doc(formattedDate);

      DocumentSnapshot attendanceSnapshot = await attendanceDoc.get();

      if (attendanceSnapshot.exists && attendanceSnapshot['taken'] == true) {
        // Attendance has been taken, show present students
        List<dynamic> present = attendanceSnapshot['present'] ?? [];
        QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('id', whereIn: present)
            .get();

        List<Map<String, dynamic>> studentList = [];
        for (var studentDoc in studentSnapshot.docs) {
          var data = studentDoc.data() as Map<String, dynamic>;
          studentList.add({
            'name': data['name'],
            'id': data['id'],
          });
        }

        setState(() {
          students = studentList;
          presentStudents = present.cast<String>(); 
          attendanceTaken = true; 
          isLoading = false;
        });
      } else {
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
            studentList.add({
              'name': data['name'],
              'id': data['id'],
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
      }
    } catch (e) {
      print("Error fetching students: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Build the student list with checkboxes
  Widget _buildStudentList(double screenWidth) {
    double fontSize = screenWidth * 0.045;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        var student = students[index];
        bool isPresent = presentStudents.contains(student['id']);
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
