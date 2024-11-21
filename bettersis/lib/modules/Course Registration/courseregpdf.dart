//import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
//import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CourseRegistrationPDF {
  final String studentId;
  final String name;
  final String program;
  final String department;
  final String academicYear;
  final String semester;
  final List<Map<String, dynamic>> courses; 

  CourseRegistrationPDF({
    required this.studentId,
    required this.name,
    required this.program,
    required this.department,
    required this.academicYear,
    required this.semester,
    required this.courses,
  });

  Future<String> generatePDF() async {
    final pdf = pw.Document();
    final iutLogo = (await rootBundle.load('assets/iut_logo.png')).buffer.asUint8List();
    final oicLogo = (await rootBundle.load('assets/oic_logo.jpg')).buffer.asUint8List();

    final currentDateTime = DateTime.now();
    final formattedTime = DateFormat('HH:mm:ss a').format(currentDateTime);  // Format the time
    final formattedDate = DateFormat('dd/MM/yyyy').format(currentDateTime);

    double totalCredit = courses.fold(0.0, (sum, course) => sum + (course['credit'] as num).toDouble());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(pw.MemoryImage(iutLogo), width: 40),
                  pw.Column(
                    children: [
                      pw.Text("Islamic University of Technology(IUT)", style: pw.TextStyle(fontSize: 18)),
                      pw.Text("(A Subsidiary Organ of the OIC)", style: pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 15),
                      pw.Text("Course Registration Form", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                    ],
                  ),
                  pw.Image(pw.MemoryImage(oicLogo), width: 50),
                ],
              ),
              pw.SizedBox(height: 25),
              // Student Information
              pw.Row(
                //mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Student ID: $studentId               "),
                  pw.Text("Programme: B.Sc in ${program.toUpperCase()}         "),
                  pw.Text("Department: ${department.toUpperCase()}"),
                ],
              ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Name: $name"),
                 // pw.Text("Department: $department"),
                  pw.Text("Academic Year: $academicYear"),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Semester: $semester"),
                  //pw.Text("Academic Year: $academicYear"),
                ],
              ),
              pw.SizedBox(height: 8),
              // Courses Table
              
              pw.Align(
                alignment: pw.Alignment.centerLeft, // Align to the top-left
                child: pw.Text(
                  "Registered Courses:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),

              //pw.Text("Registered Courses:",  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                headers: ["S/N", "Course Code", "Course Title", "Course Credit"],
                data: [
                  for (int i = 0; i < courses.length; i++)
                    [
                      pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('${i + 1}')),
                      pw.Align(alignment: pw.Alignment.center, child: pw.Text(courses[i]['code'])),
                      courses[i]['title'],
                      pw.Align(alignment: pw.Alignment.center, child: pw.Text(courses[i]['credit'].toString())),
                    ],
                    [
                            '',
                            '', 
                            pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Total   ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                            pw.Align(alignment: pw.Alignment.center, child: pw.Text(totalCredit.toStringAsFixed(2)))
                    ], // Total row
                  
                  /*...courses.asMap().entries.map((entry) {
                    int index = entry.key + 1;
                    Map<String, dynamic> course = entry.value;
                    return [
                      index.toString(),
                      course['code'],
                      course['title'],
                      course['credit'].toString(),
                    ];
                  })*/
                ],                
                //border: pw.TableBorder.all(),
                //cellAlignment: pw.Alignment.center,
              ),
              // Total Credits
             /* pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text("Total: ${totalCredit.toStringAsFixed(2)}"), /*${courses.fold(0, (sum, item) => sum + (item['credit'] as double))}*/
                ],
              ),*/
              pw.SizedBox(height: 65),
              // Signature Fields
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 200, height: 1, color: PdfColors.black),
                      pw.Align(alignment: pw.Alignment.center, child: pw.Text("Signature of the Student")),
                      pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text("Date:                              ")),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 200, height: 1, color: PdfColors.black),
                      pw.Align(alignment: pw.Alignment.center, child: pw.Text("Signature of the Student Advisor")),
                      pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text("Date:                                          ")),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 55),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 200, height: 1, color: PdfColors.black),
                      pw.Text("Head of the Department"),
                      pw.Text("Date:                              "),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 200, height: 1, color: PdfColors.black),
                      pw.Text("Registrar                                     "),
                      pw.Text("Date:                                          "),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              // Timestamp
              pw.Text(
                "This Registration form was generated at $formattedTime on $formattedDate",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final filePath = "${output.path}/course_registration.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
    
    // Download the PDF
    //await Printing.sharePdf(bytes: await pdf.save(), filename: 'course_registration.pdf');
  }
}
