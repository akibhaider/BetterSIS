import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class CourseMaterialsPage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const CourseMaterialsPage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _CourseMaterialsPageState createState() => _CourseMaterialsPageState();
}

class _CourseMaterialsPageState extends State<CourseMaterialsPage> {
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;
  String? _selectedBook;
  String? pdfUrl;

  final List<String> departments = ['cse', 'eee', 'mpe', 'cee', 'btm'];
  final Map<String, List<String>> departmentPrograms = {
    'cse': ['cse', 'swe'],
    'eee': ['eee'],
    'mpe': ['me', 'ipe'],
    'cee': ['cee'],
    'btm': ['btm'],
  };

  final List<String> semesters = [
    'semester 1', 'semester 2', 'semester 3', 'semester 4',
    'semester 5', 'semester 6', 'semester 7', 'semester 8'
  ];

  List<String> currentPrograms = [];
  List<String> currentCourses = [];
  List<String> currentBooks = [];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double paddingValue = screenWidth * 0.05;

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Course Materials',
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: ListView(
          children: [
            // Department Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Department',
                border: const OutlineInputBorder(),
              ),
              value: _selectedDepartment,
              items: departments.map((department) {
                return DropdownMenuItem<String>(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                  _selectedProgram = null;
                  currentPrograms = departmentPrograms[value!] ?? [];
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),

            // Program Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Program',
                border: const OutlineInputBorder(),
              ),
              value: _selectedProgram,
              items: currentPrograms.map((program) {
                return DropdownMenuItem<String>(
                  value: program,
                  child: Text(program),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProgram = value;
                });
              },
              isExpanded: true,
              isDense: true,
            ),
            SizedBox(height: screenHeight * 0.02),

            // Semester Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Semester',
                border: const OutlineInputBorder(),
              ),
              value: _selectedSemester,
              items: semesters.map((semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                  _selectedCourse = null;
                  _selectedBook = null;

                  // Update courses based on selected department, program, and semester
                  if (_selectedDepartment == 'cse' &&
                      _selectedProgram == 'cse' &&
                      _selectedSemester == 'semester 2') {
                    currentCourses = ['cse 4203'];
                  } else {
                    currentCourses = [];
                  }
                  currentBooks = []; // Reset books
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),

            // Course Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Course',
                border: const OutlineInputBorder(),
              ),
              value: _selectedCourse,
              items: currentCourses.map((course) {
                return DropdownMenuItem<String>(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                  // Show specific book for selected department, program, semester, and course
                  if (_selectedCourse == 'cse 4203') {
                    currentBooks = ['discrete_mathematics_kenneth_rosen_8th_ed.pdf'];
                  }
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),

            // Books Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Books',
                border: const OutlineInputBorder(),
              ),
              value: _selectedBook,
              items: currentBooks.map((book) {
                return DropdownMenuItem<String>(
                  value: book,
                  child: SizedBox(
                    width: screenWidth * 0.6, // Adjust the width as needed
                    child: Text(
                      book,
                      maxLines: 2, // Allows for up to two lines
                      overflow: TextOverflow.ellipsis, // Adds ellipsis if text is too long
                      style: TextStyle(fontSize: 14.0), // Adjust font size if needed
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedBook = value;
                });
                pdfUrl = await getBookPdfUrl(value);
                setState(() {}); // Update UI to reflect the PDF preview
              },
              isExpanded: true, // Expand to the available width
            ),
            SizedBox(height: screenHeight * 0.02),

            // PDF Preview
            if (pdfUrl != null)
              Container(
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: PDFView(
                  filePath: pdfUrl!,
                  autoSpacing: false,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  onError: (error) {
                    print(error.toString());
                  },
                ),
              )
            else
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text('No PDF Available'),
              ),
            SizedBox(height: screenHeight * 0.02),

            // Download Button
            ElevatedButton(
              onPressed: () {
                if (_selectedBook != null && pdfUrl != null) {
                  // Logic to handle download
                  print('Downloading $_selectedBook...');
                }
              },
              child: const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to retrieve PDF URL from Firebase Storage
  Future<String?> getBookPdfUrl(String? bookTitle) async {
    if (bookTitle == null || _selectedProgram == null || _selectedSemester == null || _selectedCourse == null) return null;

    final storageRef = FirebaseStorage.instance.ref().child(
      'Library/Books/${widget.userDept.toLowerCase()}/${_selectedProgram!.toLowerCase()}/${_selectedSemester!}/${_selectedCourse!}/$bookTitle.pdf',
    );

    // Print the URL path for debugging
    print('Fetching PDF URL for: Library/Books/${widget.userDept.toLowerCase()}/${_selectedProgram!.toLowerCase()}/${_selectedSemester!}/${_selectedCourse!}/$bookTitle.pdf');

    try {
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error fetching PDF URL: $e');
      return null;
    }
  }
}
