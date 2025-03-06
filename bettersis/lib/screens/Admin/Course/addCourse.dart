import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import '../../../modules/bettersis_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCoursePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const AddCoursePage({
    super.key,
    required this.userData,
    required this.onLogout,
  });

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseCreditController = TextEditingController();
  final TextEditingController _courseShortFormController =
      TextEditingController();

  bool _isElectiveEnabled = false;
  String? _selectedElective;
  String? _chosenDepartment;
  int? _chosenSemester;

  bool get _isFormEnabled =>
      _chosenDepartment != null && _chosenSemester != null;

  Future<void> addCourse() async {
    try {
      if (_chosenDepartment == null || _chosenSemester == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select department and semester.')),
        );
        return;
      }

      String courseName = _courseNameController.text.trim();
      String courseCode = _courseCodeController.text.trim();
      String courseCreditStr = _courseCreditController.text.trim();
      String courseShortForm = _courseShortFormController.text.trim();
      int elective;
      String? electiveStr = _selectedElective;

      if (courseName.isEmpty ||
          courseCode.isEmpty ||
          courseCreditStr.isEmpty ||
          courseShortForm.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields.')),
        );
        return;
      }

      // Validate course credit (should be a number)
      double? courseCredit = double.tryParse(courseCreditStr);
      if (courseCredit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Invalid course credit. Enter a numeric value.')),
        );
        return;
      }

      // Validate elective selection
      if (electiveStr == null) {
        elective = 0;
      } else if (electiveStr == 'Elective - 1') {
        elective = 1;
      } else if (electiveStr == 'Elective - 2') {
        elective = 2;
      } else {
        print('\n\n\n\n Elective invalid\n\n\n\n');
        return;
      }

      // Validate course code format
      String expectedPrefix = "${_chosenDepartment!}-4${_chosenSemester}";
      RegExp codeFormat = RegExp(r'^[A-Z]+-4\d{3}$');

      if (!codeFormat.hasMatch(courseCode) ||
          !courseCode.startsWith(expectedPrefix)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Invalid course code. Expected format: ${expectedPrefix}XX')),
        );
        return;
      }

      // Add course data to Firestore
      await FirebaseFirestore.instance
          .collection('Courses')
          .doc(_chosenDepartment!.toLowerCase()) // Department name
          .collection(_chosenSemester.toString()) // Semester
          .doc(courseCode) // Course code
          .set({
        'name': courseName,
        'credit': courseCredit, // Now stored as a number
        'short': courseShortForm,
        'elective': elective,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course added successfully!')),
      );

      // Clear fields after adding
      _courseNameController.clear();
      _courseCodeController.clear();
      _courseCreditController.clear();
      _courseShortFormController.clear();
      setState(() {
        _isElectiveEnabled = false;
        _selectedElective = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add course: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme('admin');
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Add Course',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Dropdown
              _buildDropdownRow(
                label: 'Choose Department',
                dropdown: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _chosenDepartment,
                    hint: const Text('Select'),
                    dropdownColor: theme.secondaryHeaderColor,
                    items: ['CSE', 'EEE', 'MPE', 'CEE', 'BTM'].map((dept) {
                      return DropdownMenuItem(
                        value: dept,
                        child: Text(dept, style: const TextStyle(fontSize: 18)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _chosenDepartment = value;
                      });
                    },
                  ),
                ),
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 10),

              // Semester Dropdown
              _buildDropdownRow(
                label: 'Choose Semester',
                dropdown: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _chosenSemester,
                    hint: const Text('Select'),
                    dropdownColor: theme.secondaryHeaderColor,
                    items: List.generate(8, (index) {
                      int semester = index + 1;
                      return DropdownMenuItem(
                        value: semester,
                        child: Text('Semester $semester',
                            style: const TextStyle(fontSize: 18)),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _chosenSemester = value;
                      });
                    },
                  ),
                ),
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 10),

              // Course Fields (Enabled only if department and semester are selected)
              if (_isFormEnabled) ...[
                _buildInputField('Course Name', _courseNameController,
                    screenWidth: screenWidth),
                _buildInputField('Course Code', _courseCodeController,
                    screenWidth: screenWidth),
                _buildInputField('Course Credit', _courseCreditController,
                    isNumeric: true, screenWidth: screenWidth),
                _buildInputField(
                    'Course Short Form', _courseShortFormController,
                    screenWidth: screenWidth),
                const SizedBox(height: 10),

                // Toggle Elective Button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isElectiveEnabled = !_isElectiveEnabled;
                            if (!_isElectiveEnabled) _selectedElective = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                        ),
                        child: Text(
                          _isElectiveEnabled
                              ? "Disable Elective"
                              : "Enable Elective",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Elective Dropdown (Disabled by default)
                    IgnorePointer(
                      ignoring: !_isElectiveEnabled,
                      child: DropdownButton<String>(
                        value: _selectedElective,
                        hint: const Text('Select Elective'),
                        onChanged: _isElectiveEnabled
                            ? (value) {
                                setState(() {
                                  _selectedElective = value;
                                });
                              }
                            : null,
                        items: ['Elective - 1', 'Elective - 2'].map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: addCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Create',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    'Please select department and semester first.',
                    style:
                        TextStyle(color: theme.primaryColorDark, fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Input Field Builder
  Widget _buildInputField(String label, TextEditingController controller,
      {bool isNumeric = false, required double screenWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: screenWidth > 600
            ? screenWidth * 0.5
            : double.infinity, // Adjust width based on screen size
        child: TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  // Dropdown Row Builder
  Widget _buildDropdownRow(
      {required String label,
      required Widget dropdown,
      required double screenWidth}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(255, 42, 42, 41),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: screenWidth > 600
              ? screenWidth * 0.5
              : 150, // Adjust dropdown width based on screen size
          child: dropdown,
        ),
      ],
    );
  }
}
