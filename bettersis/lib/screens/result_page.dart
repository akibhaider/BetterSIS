import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utis/themes.dart';
import 'package:flutter/material.dart';
import 'quiz_page.dart';

class ResultPage extends StatefulWidget {
  final VoidCallback onLogout;
  final Map<String, dynamic> userData;

  const ResultPage({super.key, required this.onLogout, required this.userData});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: BetterSISAppBar(onLogout: widget.onLogout, theme: theme, title: 'Result'),
        body: Column(
          children: [
            // Display Student Information
            Container(
              color: theme.primaryColor, 
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Name: \n${widget.userData['name']}',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Student ID:\n${widget.userData['id']}',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Current AY:\n2023-2024',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Current Semester:\n${widget.userData['semester']}',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Completed Credits:\n91',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // GPA Card 
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: theme.secondaryHeaderColor,
                            width: 2,
                          ),
                        ),
                        child: Card(
                          color: Colors.white.withOpacity(0.7), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Text(
                                  'GPA',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '3.69',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // CGPA Card 
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: theme.secondaryHeaderColor, 
                            width: 2,
                          ),
                        ),
                        child: Card(
                          color: Colors.white.withOpacity(0.7), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0, 
                          margin: EdgeInsets.zero,
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Text(
                                  'CGPA',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '3.75',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  print("Page changed to: $index");
                },
                children: [
                  QuizPage(userId: widget.userData['id']),
                  PageB(),
                  PageC(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Page B",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class PageC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Page C",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
