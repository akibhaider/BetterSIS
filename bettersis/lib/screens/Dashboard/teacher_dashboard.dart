import 'package:bettersis/screens/Complain/complain_page.dart';
import 'package:bettersis/screens/Teacher/Attendance/attendance.dart';
import 'package:bettersis/screens/Teacher/Classes/classes.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:flutter/material.dart';
import '../../utils/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Misc/login_page.dart';
import '../../modules/bettersis_appbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:bettersis/screens/Teacher/Academics/Course_book_manage.dart';
import 'package:bettersis/screens/Teacher/upload_course_outline.dart';

class TeacherDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const TeacherDashboard({super.key, required this.userData});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String imageUrl = '';
  String nextClassInfo = "No Classes for Today";

  @override
  void initState() {
    super.initState();
    fetchImageUrl();
    Utils.setLogout(_logout);
    _checkNextClass();
  }

  void _checkNextClass() {
    String today = DateFormat('EEEE')
        .format(DateTime.now())
        .toLowerCase(); // Get today's day
    DateTime now = DateTime.now();

    Map<String, dynamic> routine = widget.userData['routine'] ?? {};
    List<Map<String, dynamic>> todayClasses = [];

    // Filter classes for today's day
    routine.forEach((courseCode, schedule) {
      for (String classInfo in schedule) {
        List<String> parts = classInfo.split('-');
        if (parts[0] == today) {
          // Add classes for today
          DateTime startTime = _parseTime(parts[1]);
          DateTime endTime = _parseTime(parts[2]);
          todayClasses.add({
            'courseCode': courseCode,
            'startTime': startTime,
            'endTime': endTime,
            'room': parts[3]
          });
        }
      }
    });

    // Sort classes by start time
    todayClasses.sort((a, b) => a['startTime'].compareTo(b['startTime']));

    // Determine the closest class
    for (var classData in todayClasses) {
      DateTime startTime = classData['startTime'];
      DateTime endTime = classData['endTime'];

      if (now.isBefore(startTime)) {
        // Next class to take
        setState(() {
          nextClassInfo =
              "Next Class: ${classData['courseCode']} in ${classData['room']} at ${DateFormat('h:mm a').format(startTime)}";
        });
        return;
      } else if (now.isAfter(startTime) && now.isBefore(endTime)) {
        // Currently taking this class
        setState(() {
          nextClassInfo =
              "Currently Taking: ${classData['courseCode']} in ${classData['room']}";
        });
        return;
      }
    }

    // No classes remaining for today
    setState(() {
      nextClassInfo = "No Classes for Today";
    });
  }

  // Helper function to parse time (hh:mm:ss) to DateTime with today's date
  DateTime _parseTime(String time) {
    DateTime now = DateTime.now();
    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Future<void> fetchImageUrl() async {
    try {
      String email = widget.userData['email'];
      String fileName = '$email.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      String url = await storageRef.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print('Error fetching image URL: $e');
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToSubmitResult() {
    // Add Submit Result page navigation here
  }

  void _navigateToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Attendance(onLogout: _logout, userData: widget.userData)),
    );
  }

  void _navigateToAnnouncement() {
    // Add Announcement page navigation here
  }

  void _navigateToClasses() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Classes(onLogout: _logout, userData: widget.userData)),
    );
  }

  void _navigateToAcademics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseBookManagePage(
          onLogout: _logout,
          userDept: widget.userData['dept'],
        ),
      ),
    );
  }

  void _navigateToComplain() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ComplainPage(
              onLogout: _logout,
              userDept: widget.userData['dept'],
              userId: widget.userData['id'])),
    );
  }

  void _navigateToCoPoUpload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadCourseOutlinePage(
          userDept: widget.userData['dept'],
          onLogout: _logout,
        ),
      ),
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required ThemeData themeData,
    required VoidCallback onTap,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: themeData.primaryColor,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize, // Dynamic font size
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);
    final screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: BetterSISAppBar(
          onLogout: _logout,
          theme: theme,
          title: 'Dashboard',
        ),
        body: SingleChildScrollView(
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
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(imageUrl),
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
                            'Welcome!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14 * scaleFactor,
                            ),
                          ),
                          Text(
                            widget.userData['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20 * scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3.5),
                          Text(
                            "${widget.userData['designation']}, ${widget.userData['dept'].toUpperCase()}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                          const SizedBox(height: 3.5),
                          Text(
                            "${widget.userData['specialization']}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: theme.primaryColor,
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    nextClassInfo,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'SERVICES',
                  style: TextStyle(
                    fontSize: 20 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = screenWidth > 600 ? 4 : 3;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 30,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildServiceButton(
                        icon: Icons.check,
                        label: "Attendance",
                        themeData: theme,
                        onTap: _navigateToAttendance,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.announcement,
                        label: "Announcement",
                        themeData: theme,
                        onTap: _navigateToAnnouncement,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.class_,
                        label: "Classes",
                        themeData: theme,
                        onTap: _navigateToClasses,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.book,
                        label: "Book Manage",
                        themeData: theme,
                        onTap: _navigateToAcademics,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.report_problem,
                        label: "Complain",
                        themeData: theme,
                        onTap: _navigateToComplain,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.assessment,
                        label: "CO-PO Upload",
                        themeData: theme,
                        onTap: () => _navigateToCoPoUpload(context),
                        fontSize: 14 * scaleFactor,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '2024 @ HafeziCodingBlackEdition',
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
