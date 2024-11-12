import 'package:flutter/material.dart';

class CourseMaterialsPage extends StatefulWidget {
  @override
  _CourseMaterialsPageState createState() => _CourseMaterialsPageState();
}

class _CourseMaterialsPageState extends State<CourseMaterialsPage> {
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;
  String? _selectedBook;
  String? bookCoverUrl; // Holds the URL of the selected book cover image

  final List<String> programs = ['CSE', 'SWE'];
  final List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8'
  ];

  final List<String> semester1Courses = ['CSE 4105', 'CSE 4107', 'Math 4141', 'Phy 4141'];
  final List<String> semester2Courses = ['CSE 4203', 'CSE 4205', 'Math 4241', 'Phy 4241'];
  final List<String> semester3Courses = ['CSE 4301', 'CSE 4303', 'CSE 4307', 'Math 4341'];
  final List<String> semester4Courses = ['CSE 4403', 'CSE 4405', 'CSE 4407', 'Math 4441'];
  final List<String> semester5Courses = ['CSE 4501', 'CSE 4503', 'CSE 4511', 'CSE 4513'];
  final List<String> semester6Courses = ['CSE 4615', 'CSE 4619', 'CSE 4621', 'Math 4641'];
  final List<String> semester7Courses = ['CSE 4703', 'CSE 4711', 'CSE 4733', 'Math 4741'];
  final List<String> semester8Courses = ['CSE 4801', 'CSE 4803', 'CSE 4805', 'CSE 4807'];

  List<String> currentCourses = [];
  final Map<String, List<String>> semesterBooks = {
    'Semester 1': ['Introduction to Programming', 'Physics Fundamentals', 'Calculus I'],
    'Semester 2': ['Data Structures', 'Digital Logic Design', 'Calculus II'],
    'Semester 3': ['Algorithms', 'Discrete Mathematics', 'Linear Algebra'],
    'Semester 4': ['Operating Systems', 'Database Systems', 'Probability and Statistics'],
    // Additional semester books can be added as needed
  };

  List<String> currentBooks = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double paddingValue = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Materials"),
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Program',
                border: const OutlineInputBorder(),
              ),
              value: _selectedProgram,
              items: programs
                  .map((program) => DropdownMenuItem<String>(
                value: program,
                child: Text(program),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProgram = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Semester',
                border: const OutlineInputBorder(),
              ),
              value: _selectedSemester,
              items: semesters
                  .map((semester) => DropdownMenuItem<String>(
                value: semester,
                child: Text(semester),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                  _selectedCourse = null;
                  _selectedBook = null;

                  // Update courses and books based on the selected semester
                  switch (_selectedSemester) {
                    case 'Semester 1':
                      currentCourses = semester1Courses;
                      currentBooks = semesterBooks['Semester 1'] ?? [];
                      break;
                    case 'Semester 2':
                      currentCourses = semester2Courses;
                      currentBooks = semesterBooks['Semester 2'] ?? [];
                      break;
                    case 'Semester 3':
                      currentCourses = semester3Courses;
                      currentBooks = semesterBooks['Semester 3'] ?? [];
                      break;
                    case 'Semester 4':
                      currentCourses = semester4Courses;
                      currentBooks = semesterBooks['Semester 4'] ?? [];
                      break;
                    case 'Semester 5':
                      currentCourses = semester5Courses;
                      currentBooks = semesterBooks['Semester 5'] ?? [];
                      break;
                    case 'Semester 6':
                      currentCourses = semester6Courses;
                      currentBooks = semesterBooks['Semester 6'] ?? [];
                      break;
                    case 'Semester 7':
                      currentCourses = semester7Courses;
                      currentBooks = semesterBooks['Semester 7'] ?? [];
                      break;
                    case 'Semester 8':
                      currentCourses = semester8Courses;
                      currentBooks = semesterBooks['Semester 8'] ?? [];
                      break;
                    default:
                      currentCourses = [];
                      currentBooks = [];
                  }
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Course',
                border: const OutlineInputBorder(),
              ),
              value: _selectedCourse,
              items: currentCourses
                  .map((course) => DropdownMenuItem<String>(
                value: course,
                child: Text(course),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Books',
                border: const OutlineInputBorder(),
              ),
              value: _selectedBook,
              items: currentBooks
                  .map((book) => DropdownMenuItem<String>(
                value: book,
                child: Text(book),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBook = value;
                  bookCoverUrl = getBookCoverUrl(value); // Update the book cover URL based on selection
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            // Book cover preview
            if (bookCoverUrl != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.network(
                  bookCoverUrl!,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text('No Book Cover Available'),
              ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: () {
                if (_selectedBook != null) {
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

  // Method to retrieve book cover URL (replace with actual logic to fetch URLs)
  String? getBookCoverUrl(String? bookTitle) {
    // Placeholder URLs for demonstration purposes
    final Map<String, String> bookCovers = {
      'Introduction to Programming': 'https://example.com/programming-cover.jpg',
      'Physics Fundamentals': 'https://example.com/physics-cover.jpg',
      'Calculus I': 'https://example.com/calculus-cover.jpg',
      'Data Structures': 'https://example.com/data-structures-cover.jpg',
    };
    return bookCovers[bookTitle];
  }
}
