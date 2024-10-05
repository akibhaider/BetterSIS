import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final String userId;

  const QuizPage({Key? key, required this.userId}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool isLoading = false;

  Future<List<String>> _fetchSemesters() async {
    // Fetch semesters for the user
    QuerySnapshot semesterSnapshot = await FirebaseFirestore.instance
      .collection('Results')
      .doc('Quiz')
      .collection(widget.userId)
      .get();

    List<String> semesters = semesterSnapshot.docs.map((doc) => doc.id).toList();
    return semesters;
  }

  Future<List<String>> _fetchCourses(String semesterId) async {
    // Fetch courses for the selected semester
    QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
      .collection('Results')
      .doc('Quiz')
      .collection(widget.userId)
      .doc(semesterId)
      .collection('Courses')
      .get();

    List<String> courses = courseSnapshot.docs.map((doc) => doc.id).toList();
    return courses;
  }

  Future<Map<String, dynamic>> _fetchQuizMarks(String semesterId, String courseId) async {
  // Fetch marks for the selected course
  DocumentSnapshot marksSnapshot = await FirebaseFirestore.instance
      .collection('Results')
      .doc('Quiz')
      .collection(widget.userId)
      .doc(semesterId)
      .collection('Courses')
      .doc(courseId)
      .get();

  // Check if the document exists and return the marks
  if (marksSnapshot.exists) {
    return {
      'marks': marksSnapshot['marks'], 
    };
  } else {
    throw Exception('Marks document not found');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: FutureBuilder<List<String>>(
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
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                String semesterId = semesters[index];
                return ExpansionTile(
                  title: Text('Semester $semesterId'),
                  children: [
                    FutureBuilder<List<String>>(
                      future: _fetchCourses(semesterId),
                      builder: (context, courseSnapshot) {
                        if (courseSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (courseSnapshot.hasError) {
                          return const Text('Error fetching courses');
                        } else if (!courseSnapshot.hasData || courseSnapshot.data!.isEmpty) {
                          return const Text('No courses found');
                        } else {
                          List<String> courses = courseSnapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true, // Ensures ListView fits inside the ExpansionTile
                            physics: const NeverScrollableScrollPhysics(), // Prevents inner ListView from scrolling
                            itemCount: courses.length,
                            itemBuilder: (context, courseIndex) {
                              String courseId = courses[courseIndex];
                              return ExpansionTile(
                                title: Text(courseId),
                                children: [
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: _fetchQuizMarks(semesterId, courseId),
                                    builder: (context, quizSnapshot) {
                                      if (quizSnapshot.connectionState == ConnectionState.waiting) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16.0),
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      } else if (quizSnapshot.hasError) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16.0),
                                          child: Text('Error fetching marks'),
                                        );
                                      } else if (!quizSnapshot.hasData || quizSnapshot.data!.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16.0),
                                          child: Text('No marks found'),
                                        );
                                      } else {
                                        Map<String, dynamic> marks = quizSnapshot.data!;
                                        return ListTile(
                                          title: Text('Marks: ${marks['marks']}'), // Display marks
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
    );
  }
}
