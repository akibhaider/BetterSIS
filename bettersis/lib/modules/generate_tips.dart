import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GenerateTips extends StatefulWidget {
  final Map<String, dynamic> userData;

  const GenerateTips({super.key, required this.userData});

  @override
  _GenerateTipsState createState() => _GenerateTipsState();
}

class _GenerateTipsState extends State<GenerateTips> {
  Map<String, int> courseMarks = {};
  bool _isLoading = true;
  String aiResponse = '';

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
  );

  @override
  void initState() {
    super.initState();
    _fetchMidMarks();
  }

  // Function to fetch the mid-term marks for the user
  Future<void> _fetchMidMarks() async {
    try {
      QuerySnapshot midResults = await FirebaseFirestore.instance
          .collection('Results')
          .doc('Mid')
          .collection(widget.userData['id'])
          .doc(widget.userData['semester'][0])
          .collection('Courses')
          .get();

      if (midResults.docs.isNotEmpty) {
        for (var doc in midResults.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String courseCode = doc.id; 
          int midMark = data['marks'] ?? 0; 

          String? courseName = await _fetchCourseName(courseCode);
          courseMarks[courseName ?? courseCode] = midMark;
        }

        await _getImprovementTips();
      } else {
        setState(() {
          _isLoading = false;
          aiResponse = 'Mid-Term has not occurred yet.';
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        aiResponse = 'Error fetching mid-term marks: $error';
      });
    }
  }

  Future<String?> _fetchCourseName(String courseID) async {
    try {
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(widget.userData['dept'])
          .collection(widget.userData['semester'][0])
          .doc(courseID)
          .get();

      if (courseDoc.exists) {
        Map<String, dynamic>? data = courseDoc.data() as Map<String, dynamic>?;

        String? courseName = data?['name'];

        return courseName ?? 'Unknown Course';
      } else {
        return 'Course not found';
      }
    } catch (error) {
      print('Error fetching course name: $error');
      return 'Error fetching course';
    }
  }

  Future<void> _getImprovementTips() async {
    if (courseMarks.isEmpty) return;

    String prompt = '''
      Here are the mid-term marks for ${widget.userData['name']}:
      ${courseMarks.entries.map((e) => 'Course: ${e.key}, Marks: ${e.value}').join(', ')}.
      The full marks for each course are 75. 
      Can you provide advice on how ${widget.userData['name']} can improve in the final exams for each course? 
    ''';

    try {
      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);

      setState(() {
        _isLoading = false;
        aiResponse = response.text ?? 'No response from AI.';
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        aiResponse = 'Error fetching advice from AI: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        height: screenHeight * 0.75,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Improvement Tips',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Expanded(
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        data: aiResponse,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
