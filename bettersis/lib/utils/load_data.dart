import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';

class UploadExcelFromAssets extends StatefulWidget {
  @override
  _UploadExcelFromAssetsState createState() => _UploadExcelFromAssetsState();
}

class _UploadExcelFromAssetsState extends State<UploadExcelFromAssets> {
  // Future<void> _loadExcelFromAssetsAndUpload() async {
  //   // Load the Excel file from the assets
  //   ByteData data = await rootBundle.load('assets/students_data.xlsx');
  //   var bytes = data.buffer.asUint8List();
  //   var excel = Excel.decodeBytes(bytes);

  //   // Iterate through the rows in the Excel sheet
  //   for (var table in excel.tables.keys) {
  //     var sheet = excel.tables[0];

  //     if (sheet == null) continue;

  //     for (var row in sheet.rows.skip(1)) {
  //       // Ignore the first two columns (Timestamp, Email Address)
  //       String name = row[2]?.toString() ?? '';
  //       String id = row[3]?.toString() ?? '';
  //       String phone = row[4]?.toString() ?? '';
  //       String section = row[5]?.toString() ?? '';
  //       String dept = row[6]?.toString() ?? '';
  //       String program = row[7]?.toString() ?? '';
  //       String semester = row[8]?.toString() ?? '';

  //       print("$name $id $phone $section $dept $program $semester");

  // // Upload user data to Firestore
  // await _uploadUserToFirestore(
  //   name,
  //   id,
  //   phone,
  //   section,
  //   dept,
  //   program,
  //   semester,
  // );
  //     }
  //   }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Excel data uploaded successfully!')),
  //   );
  // }

  Future<void> _loadExcelFromAssetsAndUpload() async {
    // Load the Excel file from the assets
    ByteData data = await rootBundle.load('assets/students_data.xlsx');
    var bytes = data.buffer.asUint8List();
    var excel = Excel.decodeBytes(bytes);

    // Iterate through the rows in the Excel sheet
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];

      if (sheet == null) continue;

      // Iterate through each row starting from row 1 (skipping header)
      for (var row in sheet.rows.skip(1)) {
        // Extract values from the row, skipping the first two columns
        String name = row[2]?.value.toString() ?? '';
        String email = row[3]?.value.toString() ?? '';
        String id = row[4]?.value.toString() ?? '';
        String phone = row[5]?.value.toString() ?? '';
        String section = row[6]?.value.toString() ?? '';
        String dept = row[7]?.value.toString() ?? '';
        String program = row[8]?.value.toString() ?? '';
        String semester = row[9]?.value.toString() ?? '';

        // Print values for debugging
        print('Full Name: $name');
        print('Email: $email');
        print('ID: $id');
        print('Phone: $phone');
        print('Section: $section');
        print('Department: $dept');
        print('Program: $program');
        print('Semester: $semester');

        // Upload user data to Firestore
        await _uploadUserToFirestore(
          name,
          email,
          id,
          phone,
          section,
          dept,
          program,
          semester,
        );
      }
    }
  }

  Future<void> _uploadUserToFirestore(
    String name,
    String email,
    String id,
    String phone,
    String section,
    String dept,
    String program,
    String semester,
  ) async {
    try {
      // Add user to the "Users" collection with auto-generated document ID
      DocumentReference userRef =
          await FirebaseFirestore.instance.collection('Users').add({
        'name': name,
        'email': email,
        'id': id,
        'phone': phone,
        'section': section,
        'dept': dept,
        'program': program,
        'semester': semester,
        'cr': false,
        'type': 'student'
      });

      // Create the "Enrolled Courses" subcollection under the newly created user document
      await _createEnrolledCourses(userRef);

      print("User $name (ID: $id) added successfully.");
    } catch (e) {
      print("Error uploading user $name: $e");
    }
  }

  Future<void> _createEnrolledCourses(DocumentReference userRef) async {
    // Create documents 1 to 8 in the "Enrolled Courses" subcollection
    for (int i = 1; i <= 8; i++) {
      DocumentReference enrolledCourseRef =
          userRef.collection('Enrolled Courses').doc(i.toString());

      // Set 'registered' field to false
      await enrolledCourseRef.set({
        'registered': false,
      });

      // Add the default courses in "Course List" subcollection
      await enrolledCourseRef.collection('Course List').doc('CSE-4513').set({
        'name': 'Software Engineering and Object Oriented Design',
      });
      await enrolledCourseRef.collection('Course List').doc('CSE-4510').set({
        'name': 'Software Development',
      });
    }

    print('Enrolled courses created.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Excel from Assets to Firestore')),
      body: Center(
        child: ElevatedButton(
          onPressed: _loadExcelFromAssetsAndUpload,
          child: Text('Upload Excel Data'),
        ),
      ),
    );
  }
}
