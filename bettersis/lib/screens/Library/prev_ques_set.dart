// import 'package:flutter/material.dart';

// void main() {
//   runApp(LibraryApp());
// }

// class LibraryApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BetterSIS Library',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LibraryHomePage(),
//     );
//   }
// }

// class LibraryHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Icon(Icons.menu),
//         title: Text('BetterSIS'),
//         centerTitle: true,
//         actions: [
//           Icon(Icons.settings),
//           Stack(
//             children: <Widget>[
//               Icon(Icons.notifications),
//               Positioned(
//                 right: 0,
//                 child: Container(
//                   padding: EdgeInsets.all(1),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   constraints: BoxConstraints(
//                     minWidth: 12,
//                     minHeight: 12,
//                   ),
//                   child: Text(
//                     '1',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 8,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => PreviousQuestionPanel()),
//             );
//           },
//           child: Text('PREVIOUS QUESTIONS'),
//         ),
//       ),
//     );
//   }
// }

// class PreviousQuestionPanel extends StatefulWidget {
//   @override
//   _PreviousQuestionPanelState createState() => _PreviousQuestionPanelState();
// }

// class _PreviousQuestionPanelState extends State<PreviousQuestionPanel> {
//   String selectedQuestion = 'Select a question to preview';
//   List<String> questions = [
//     'Question Set 1',
//     'Question Set 2',
//     'Question Set 3',
//   ];
//   String searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Search Previous Questions'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search Bar
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search questions...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//             ),
//             SizedBox(height: 20),
//             // Dropdown to Select a Question
//             DropdownButton<String>(
//               value: selectedQuestion,
//               icon: Icon(Icons.arrow_downward),
//               isExpanded: true,
//               items: questions
//                   .where((q) =>
//                       q.toLowerCase().contains(searchQuery.toLowerCase()))
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   selectedQuestion = newValue!;
//                 });
//               },
//               underline: Container(
//                 height: 2,
//                 color: Colors.blue,
//               ),
//             ),
//             SizedBox(height: 20),
//             // Preview Section
//             Expanded(
//               child: Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: selectedQuestion == 'Select a question to preview'
//                     ? Text(
//                         'Preview will be shown here',
//                         style: TextStyle(color: Colors.grey),
//                       )
//                     : Text(
//                         'Preview of $selectedQuestion',
//                         style: TextStyle(fontSize: 18),
//                       ),
//               ),
//             ),
//             SizedBox(height: 20),
//             // Download Button
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Handle download action
//               },
//               icon: Icon(Icons.download),
//               label: Text('Download'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.blue,
//                 minimumSize: Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

