
import 'package:bettersis/screens/Admin/Course/addCourse.dart';
import 'package:bettersis/screens/Admin/Course/deleteCourse.dart';
import 'package:bettersis/screens/Admin/Course/editCourse.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import '../../../modules/bettersis_appbar.dart';

class mainCoursePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const mainCoursePage({
    super.key,
    required this.userData,
    required this.onLogout,
  });

  @override
  State<mainCoursePage> createState() => _mainCoursePageState();
}

class _mainCoursePageState extends State<mainCoursePage> {

  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme('admin'); 
    final Size screenSize = MediaQuery.of(context).size;
    final double buttonSize = screenSize.width * 0.3; 
    List<Map<String, dynamic>> options = [
      {
        'label': 'Add Course',
        'icon': Icons.add_rounded,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCoursePage(onLogout: widget.onLogout, userData: widget.userData),
            ),
          );
        }
      },
      {
        'label': 'Edit Course',
        'icon': Icons.edit_rounded,
        'onPressed': () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => EditCoursePage(), // Implement EditCoursePage
          //   ),
          // );
        }
      },
      {
        'label': 'Delete Course',
        'icon': Icons.delete_rounded,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeleteCoursePage(onLogout: widget.onLogout, userData: widget.userData), // Implement DeleteCoursePage
            ),
          );
        }
      },
    ];

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Courses',
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenSize.height * 0.03,
            left: screenSize.width * 0.05,
            right: screenSize.width * 0.05,
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return _buildCircularButton(
                theme: theme,
                label: options[index]['label'],
                icon: options[index]['icon'],
                onPressed: options[index]['onPressed'],
                buttonSize: buttonSize,
              );
            },
          ),
        ),
      ),
    );
  }

  // Method to build a circular button with icon and label
  Widget _buildCircularButton({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required double buttonSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: buttonSize * 0.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: buttonSize * 0.12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}