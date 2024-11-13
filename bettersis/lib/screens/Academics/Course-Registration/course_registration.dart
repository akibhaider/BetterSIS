import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CourseRegistration extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String imageUrl;
  final VoidCallback onLogout;

  const CourseRegistration({
    super.key,
    required this.userData,
    required this.imageUrl,
    required this.onLogout,
  });

  @override
  State<CourseRegistration> createState() => _CourseRegistrationState();
}

class _CourseRegistrationState extends State<CourseRegistration> {
  // Number of courses and course data
  //int totalCourses = 10; 
  
  List<Map<String, dynamic>> offeredCourses = [];

  List<Map<String, dynamic>> selectedCourses = [];

  Future<void> fetchData() async {
    try{
      List<Map<String, dynamic>> tempCourses = [];

      String sem = widget.userData['semester'];
      String cleanSem = sem.replaceAll(RegExp(r'[^0-9]'), '');

      QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection('Courses')
        .doc(widget.userData['dept'])
        .collection(cleanSem)
        .get();
 
      for(var course in courseSnapshot.docs){
        Map<String, dynamic> courseData = course.data() as Map<String, dynamic>;

        tempCourses.add({
          'code': course.id,
          'title': courseData['name'],
          'credit': courseData['credit'],
          //'short': courseData['short'],
        });
      }

      setState(() {
        offeredCourses = tempCourses;
        print('offeredCourses updated: $offeredCourses');
      });
    }

    catch(error){
      print('\x1B[31mError Fetching\x1B[0m');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375;

    const String currentAcademicYear = '2023-2024';

    return Scaffold(
        backgroundColor: theme.primaryColor,
        drawer: CustomAppDrawer(theme: theme),
        appBar: BetterSISAppBar(
          onLogout: widget.onLogout,
          theme: theme,
          title: 'Course Registration',
        ),
        body: Column(
        children: [
          // Blue Box for Profile Information
          Container(
            padding: const EdgeInsets.all(13.0),
            width: double.infinity,
            color: theme.primaryColor,
            child: Column(
              children: [
                Container(
                color: theme.primaryColor,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, 
                          width: 4.0,
                        ),
                        boxShadow: widget.userData['cr']
                            ? [
                                BoxShadow(
                                  color: Colors.white
                                      .withOpacity(0.7), 
                                  spreadRadius: 8, 
                                  blurRadius: 15, 
                                ),
                              ]
                            : [], 
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(widget.imageUrl),
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Error loading image: $exception');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userData['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20 * scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.secondaryHeaderColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                            "${widget.userData['id']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                          ),
                          
                          const SizedBox(height: 4),
                          Text(
                            "Department: ${widget.userData['dept'].toString().toUpperCase()}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Program: BSc in ${widget.userData['program'].toString().toUpperCase()}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13 * scaleFactor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                const SizedBox(height: 2),
                const Divider(color: Colors.white),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Semester: ${widget.userData['semester']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Current AY: $currentAcademicYear',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              //color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'OFFERED COURSES',
                      style: TextStyle(
                        color: theme.secondaryHeaderColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: offeredCourses.length,
                      itemBuilder: (context, index) {
                        final course = offeredCourses[index];
                        bool isSelected = selectedCourses.contains(course);
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            title: Text(
                              course['code']!,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course['title']),
                                Text('${course['credit']} credit'),
                              ],
                            ),
                            //Text('${course['title']} - ${course['credit']} credit'),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedCourses.remove(course);
                                  } else {
                                    selectedCourses.add(course);
                                  }
                                });
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: isSelected ? theme.primaryColor : Colors.grey.shade300,
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ]
              )
            ),
          ),
        ],
      ),
    );
  }
}
