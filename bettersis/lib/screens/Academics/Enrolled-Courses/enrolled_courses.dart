import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Academics/Course-Registration/crpdfscreen.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Course-Registration/crpdfscreen.dart';
import 'package:flutter/material.dart';

class EnrolledCourses extends StatefulWidget {
  final String userDept;
  final String userId;
  final String userName;
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const EnrolledCourses({
    required this.userDept,
    required this.userId,
    required this.onLogout,
    required this.userName,
    required this.userData,
    super.key,
  });

  @override
  _EnrolledCoursesState createState() => _EnrolledCoursesState();
}

class _EnrolledCoursesState extends State<EnrolledCourses> {
  int? chosenSemester;
  List<Map<String, dynamic>> enrolledCourses = [];
  bool isLoading = false;
  bool isRegistered = false;
  bool hasShown = false;

  // Function to fetch courses based on chosen semester
  Future<void> fetchCourses(int semester) async {
    setState(() {
      isLoading = true;
      enrolledCourses.clear();
    });

    try {
      // Query to get the document with the required stdID
      print('\n\n\n$chosenSemester\n\n\n');

      bool tempReg = false;
      List<Map<String, dynamic>> tempCourses = [];
      
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot document = querySnapshot.docs.first;

        DocumentSnapshot semesterDoc = await document.reference
            .collection('Enrolled Courses')
            .doc(chosenSemester.toString())
            .get();

        tempReg = semesterDoc['registered'];

        QuerySnapshot semesterColl = await document.reference
          .collection('Enrolled Courses')
          .doc(chosenSemester.toString())
          .collection('Course List')
          .get();

        for(var course in semesterColl.docs){
          Map<String, dynamic> courseData = course.data() as Map<String, dynamic>;

          tempCourses.add({
            'code': course.id,
            'title': courseData['title'],
            'credit': courseData['credit'],
            'short': courseData['short'],
          });
        }

        setState(() {
          enrolledCourses = tempCourses;
          isRegistered = tempReg;
        });
      } 
      else {
        print("No document found with ID: ${widget.userId}");
      }
    } catch (e) {
      print("Error fetching courses: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void _getCourseRegistrationForm() {
    print("Get Course Registration Form button was pressed");
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => crpdfScreen(
          userData: widget.userData, 
          courses: enrolledCourses, 
          onLogout: widget.onLogout,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Enrolled Courses',
      ),
      body: Column(
        children: [
          // Blue container with dropdown
          Container(
            color: theme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Choose Semester',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                DropdownButtonHideUnderline(
                  //width:160,
                  child: DropdownButton<int>(
                    value: chosenSemester,
                    hint: const Text(
                      'Select',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    dropdownColor: theme.secondaryHeaderColor,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: List.generate(8, (index) {
                      int semester = index + 1;
                      return DropdownMenuItem(
                        value: semester,
                        child: Text('Semester $semester', style: TextStyle(fontSize: 18),),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        chosenSemester = value;
                        hasShown = true;
                        if (chosenSemester != null) {
                          fetchCourses(chosenSemester!);
                        }
                      });
                    },
                    icon: Icon(
                      Icons.arrow_drop_down_circle_sharp,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Display courses in a scrollable ListView
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : enrolledCourses.isEmpty
                    ? Center(
                        child: Text(
                          chosenSemester == null
                              ? 'Please select a semester.'
                              : 'No courses enrolled for this semester.',
                          style: TextStyle(
                            color: theme.primaryColorDark,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: enrolledCourses.length,
                        itemBuilder: (context, index) {
                          final course = enrolledCourses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course['title'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColorDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${course['code']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${course['credit']} Credits',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // Floating button to get registration form
      floatingActionButton: (chosenSemester != null && enrolledCourses.isNotEmpty)
      ? FloatingActionButton(
          onPressed: _getCourseRegistrationForm,
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          tooltip: 'Get Course Registration Form',
          child: const Icon(Icons.assignment_turned_in_sharp), 
        )
    
      : null
    );
  }
}

