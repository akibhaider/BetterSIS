
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import '../../../modules/bettersis_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';

class DeleteCoursePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const DeleteCoursePage({
    super.key,
    required this.userData,
    required this.onLogout,
  });
  
  @override
  _DeleteCoursePageState createState() => _DeleteCoursePageState();
}

class _DeleteCoursePageState extends State<DeleteCoursePage> {
  List<Map<String, dynamic>> enrolledCourses = [];
  int? chosenSemester;
  String? chosenDepartment;
  bool isLoading = false;
  bool hasShown = false;

  void fetchCourses(String department, int semester) async {
    try{
      setState(() {
        isLoading = true;
        enrolledCourses.clear();
      });

      List<Map<String, dynamic>> tempCourses = [];

      print('\n\n\n $semester ------- $department \n\n\n');
      QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection('Courses')
        .doc(department.toLowerCase())
        .collection(semester.toString())
        .get();

      
      print('\n\n\n done \n\n\n');
      for(var course in courseSnapshot.docs){
        print('\n\n ${course.id} \n\n\n');
        Map<String, dynamic> courseData = course.data() as Map<String, dynamic>;

        tempCourses.add({
          'code': course.id,
          'title': courseData['name'],
          'credit': courseData['credit'],
          'short': courseData['short'],
        });
      }

      print('\n\n\n done \n\n\n');
      for(var course in tempCourses){
        print('${course['code']} --------- ${course['title']}');
        print('\n\n');
      }

      setState(() {
        enrolledCourses = tempCourses;
        isLoading = false;
      });
    }

    catch(error){
      print('\x1B[31mError Fetching\x1B[0m');
    }
  }

  void deleteCourse(String courseId, String department, int semester) async {
    try {
    // Show loading indicator while deleting
      setState(() {
        isLoading = true;
      });

      if (chosenDepartment == null || chosenSemester == null) {
        throw Exception('Department or Semester is not selected');
      }

    print('\n\n\n $courseId \n\n\n');

      print('\n\n\n $courseId \n\n\n');

      // Perform Firestore delete operation
      await FirebaseFirestore.instance
          .collection('Courses')
          .doc(department.toLowerCase()) // Department from the selected one
          .collection(semester.toString()) // Semester
          .doc(courseId) // Course ID to delete
          .delete();

      // After deleting, remove the course from the local list (enrolledCourses)
      setState(() {
        enrolledCourses.removeWhere((course) => course['code'] == courseId);
        isLoading = false;
      });

      // Show success message (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course deleted successfully!')),
      );
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      // Handle errors (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete course!')),
      );
      print('Error deleting course: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme('admin');

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Delete Course',
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 53, 53, 53),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose Department',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: chosenDepartment,
                        hint: const Text(
                          'Select',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        dropdownColor: theme.secondaryHeaderColor,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: ['CSE', 'EEE', 'MPE', 'CEE', 'BTM'].map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept, style: const TextStyle(fontSize: 18)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            chosenDepartment = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
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
                    DropdownButtonHideUnderline(
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
                            child: Text('Semester $semester', style: const TextStyle(fontSize: 18)),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            chosenSemester = value;
                            if (chosenDepartment != null && chosenSemester != null) {
                              fetchCourses(chosenDepartment!, chosenSemester!);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : enrolledCourses.isEmpty
                    ? Center(
                        child: Text(
                          (chosenSemester == null || chosenDepartment == null)
                              ? 'Please select department and semester.'
                              : 'No courses available.',
                          style: TextStyle(
                            color: theme.primaryColorDark,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 14, right: 10, left: 10, bottom: 20.0),
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
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Row for Credit and Delete button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          if (chosenDepartment != null && chosenSemester != null) {
                                            print('\n\n\n Here ---- $chosenDepartment ------ $chosenSemester ------- ${course['id']} \n\n\n');
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Confirm Deletion'),
                                                  content: const Text('Are you sure you want to delete this course?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: const Text('No'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteCourse(course['code'], chosenDepartment!, chosenSemester!);
                                                        Navigator.of(context).pop(); // Close the dialog after confirming
                                                      },
                                                      child: const Text('Yes'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } 
                                          else {
                                            print('\n\n\nnull error\n\n\n');
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                                  255, 219, 58, 47), // Use backgroundColor instead of primary
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                        icon: const Icon(Icons.delete, color: Colors.white),
                                        label: const Text('Delete', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }


}