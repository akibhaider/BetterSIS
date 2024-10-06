import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/final_course_details.dart';

class FinalPage extends StatefulWidget {
  final String userId;
  final String userSemester;
  final String userDept;
  final ThemeData theme;

  const FinalPage(
      {super.key,
      required this.userId,
      required this.userSemester,
      required this.userDept,
      required this.theme});

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  bool isLoading = false;

  Future<List<String>> _fetchSemesters() async {
    QuerySnapshot semesterSnapshot = await FirebaseFirestore.instance
        .collection('Results')
        .doc('Final')
        .collection(widget.userId)
        .get();

    return semesterSnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<double> _fetchGPA(String semesterId) async {
    DocumentSnapshot gpaSnapshot = await FirebaseFirestore.instance
        .collection('Results')
        .doc('Final')
        .collection(widget.userId)
        .doc(semesterId)
        .get();

    if (gpaSnapshot.exists) {
      return (gpaSnapshot.data() as Map<String, dynamic>)['gpa'] ?? 0.0;
    } else {
      throw Exception('GPA document not found');
    }
  }

  Future<List<String>> _fetchCourses(String semesterId) async {
    QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection('Results')
        .doc('Final')
        .collection(widget.userId)
        .doc(semesterId)
        .collection('Courses')
        .get();

    return courseSnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<Map<String, dynamic>> _fetchFinalMarks(
      String semesterId, String courseId) async {
    DocumentSnapshot marksSnapshot = await FirebaseFirestore.instance
        .collection('Results')
        .doc('Final')
        .collection(widget.userId)
        .doc(semesterId)
        .collection('Courses')
        .doc(courseId)
        .get();

    if (marksSnapshot.exists) {
      return {
        'marks': marksSnapshot['marks'],
      };
    } else {
      throw Exception('Marks document not found');
    }
  }

  void _showCourseDetails(Map<String, dynamic> result, String courseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.9,
            child: FinalCourseDetails(
                result: result, course: courseId, userDept: widget.userDept),
          ),
        );
      },
    );
  }

  String _getOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.3,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).secondaryHeaderColor,
              ],
            ),
          ),
          child: const Center(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Final Result',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // To make the whole body scrollable
          child: Padding(
            padding:
                const EdgeInsets.all(8.0), // Add padding to avoid edge overflow
            child: FutureBuilder<List<String>>(
              future: _fetchSemesters(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No semesters found'));
                } else {
                  List<String> semesters = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap:
                        true, // Allows the ListView to shrink and scroll
                    physics:
                        const NeverScrollableScrollPhysics(), // Avoid double scroll issue
                    itemCount: semesters.length,
                    itemBuilder: (context, index) {
                      String semesterId = semesters[index];
                      return ExpansionTile(
                        title: Text(
                            '${_getOrdinal(int.parse(semesters[index]))} Semester',
                            style: const TextStyle(fontSize: 20)),
                        children: [
                          FutureBuilder<double>(
                            future: _fetchGPA(semesterId),
                            builder: (context, gpaSnapshot) {
                              if (gpaSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                );
                              } else if (gpaSnapshot.hasError) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Error fetching GPA'),
                                );
                              } else if (!gpaSnapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('GPA not available'),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('GPA: ${gpaSnapshot.data}',
                                      style: const TextStyle(fontSize: 16)),
                                );
                              }
                            },
                          ),
                          FutureBuilder<List<String>>(
                            future: _fetchCourses(semesterId),
                            builder: (context, courseSnapshot) {
                              if (courseSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (courseSnapshot.hasError) {
                                return const Text('Error fetching courses');
                              } else if (!courseSnapshot.hasData ||
                                  courseSnapshot.data!.isEmpty) {
                                return const Text('No courses found');
                              } else {
                                List<String> courses = courseSnapshot.data!;
                                return ListView.builder(
                                  shrinkWrap:
                                      true, // Allows the ListView to shrink
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Prevent scroll collision
                                  itemCount: courses.length,
                                  itemBuilder: (context, courseIndex) {
                                    String courseId = courses[courseIndex];
                                    return ExpansionTile(
                                      title: Text(courseId),
                                      children: [
                                        FutureBuilder<Map<String, dynamic>>(
                                          future: _fetchFinalMarks(
                                              semesterId, courseId),
                                          builder: (context, quizSnapshot) {
                                            if (quizSnapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16.0),
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              );
                                            } else if (quizSnapshot.hasError) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16.0),
                                                child: Text(
                                                    'Error fetching marks'),
                                              );
                                            } else if (!quizSnapshot.hasData ||
                                                quizSnapshot.data!.isEmpty) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16.0),
                                                child: Text('No marks found'),
                                              );
                                            } else {
                                              Map<String, dynamic> marks =
                                                  quizSnapshot.data!;
                                              return ElevatedButton(
                                                onPressed: () {
                                                  _showCourseDetails(
                                                      marks, courseId);
                                                },
                                                child: const Text(
                                                    'View Course Details'),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
