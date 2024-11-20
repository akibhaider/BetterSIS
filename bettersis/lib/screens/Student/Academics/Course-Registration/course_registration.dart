import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Enrolled-Courses/enrolled_courses.dart';

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
  double totalCredits = 0.0;
  bool isLoading = true;
  bool isRegistered = false;

  List<Map<String, dynamic>> offeredCourses = [];

  List<Map<String, dynamic>> selectedCourses = [];

  Future<void> fetchData() async {
    try{
      List<Map<String, dynamic>> tempCourses = [];
      bool tempReg = false;

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
          'short': courseData['short'],
        });
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: widget.userData['id'])
        .get();
      
      if(querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot document = querySnapshot.docs.first;

        DocumentSnapshot semesterDoc = await document.reference
          .collection('Enrolled Courses')
          .doc(cleanSem)
          .get();

        tempReg = semesterDoc['registered'];
      }

      else{
        print("\n\n\n\n\n\nNo document found\n\n\n\n");
      }

      setState(() {
        offeredCourses = tempCourses;
        isRegistered = tempReg;
        isLoading = false;
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
    setTotalCreds();
  }

  void setTotalCreds(){
    double total = 0.0;

    for(var course in selectedCourses){
      total += course['credit'];
      print('\n\n\n\n\n${course['credit']} - $total\n\n\n\n');
    }

    setState(() {
      totalCredits = total;
    });

  }

  Future<void> registerCourses() async {
    try{
      String sem = widget.userData['semester'];
      String cleanSem = sem.replaceAll(RegExp(r'[^0-9]'), '');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: widget.userData['id'])
        .get();

      if(querySnapshot.docs.isNotEmpty){
        DocumentSnapshot document = querySnapshot.docs.first;

        DocumentReference semesterDoc = document.reference
          .collection('Enrolled Courses')
          .doc(cleanSem);

        for(var courses in selectedCourses){
          await semesterDoc.collection('Course List').doc(courses['code']).set({            
            'title' : courses['title'],
            'credit': courses['credit'],
            'short' : courses['short'],
          });
        }

        await semesterDoc.update({
          'registered': true,
        });

        setState(() {
          isRegistered = true;
        });

        print("\n\n\n\n\nCourses added Successfully\n\n\n\n");
      }

      else{
        print("\n\n\n\n\n\nNo document found\n\n\n\n");
      }
    }

    catch(error){
      print('\x1B[31mError Adding\x1B[0m');
    }
  }

  void navigateToEnrolled() {
    // Extract semester from user data
    // String sem = widget.userData['semester'];
    // String cleanSem = sem.replaceAll(RegExp(r'[^0-9]'), '');

    // Navigate to EnrolledCourses page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnrolledCourses(
          userDept: widget.userData['dept'],
          userId: widget.userData['id'], 
          userName: widget.userData['name'], 
          userData: widget.userData,
          onLogout: widget.onLogout,
        ),
      ),
    );
    }

  void _showNavigationConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Your registration is complete."),
          content: const Text(
            "You can get the registration form in Enrolled Courses.\nWould you like to view your enrolled courses now?"
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss this dialog
                navigateToEnrolled(); // Navigate to EnrolledCourses page
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss this dialog and stay on the current page
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }  

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text(
            "Course Registration can be done only once.\nAre you sure you want to proceed?"
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("Submit pressed");
                registerCourses();
                Navigator.of(context).pop(); // Dismiss on Yes
                _showNavigationConfirmationDialog();
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Dismiss on No
              child: const Text("No"),
            ),
          ],
        );
      },
    );
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

        floatingActionButton: (!isRegistered && !isLoading)
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: FloatingActionButton.extended(
                onPressed: _showConfirmationDialog,
                label: const Text("Submit", style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
                //icon: const Icon(Icons.check),
                backgroundColor: theme.primaryColor,
              )
            )
          : null,

        body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white),)
          : Column(
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
                  padding: const EdgeInsets.only(left: 12.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                //color: Colors.white,
                child: !isRegistered
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OFFERED COURSES',
                                style: TextStyle(
                                  color: theme.secondaryHeaderColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 *scaleFactor,
                                ),
                              ),
                              //const SizedBox(width: 15),
                              const Spacer(),
                              Text(
                                "Total Credits: $totalCredits",
                                style: TextStyle(
                                  color: theme.secondaryHeaderColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 * scaleFactor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 70.0),
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
                                  
                                  trailing: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedCourses.remove(course);
                                          setTotalCreds();
                                        } else {
                                          selectedCourses.add(course);
                                          setTotalCreds();
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
                : Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "The course registration is completed. View the selected courses and print the course registration form in Enrolled Courses page.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 16 * scaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
              ),
            ),
          ],
        ),
    );
  }
}
