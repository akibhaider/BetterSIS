import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Library/resource_front_page.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class Library extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;

  const Library({
    super.key,
    required this.userId,
    required this.userDept,
    required this.userName,
    required this.onLogout,
  });

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Library',
      ),
      body: ResourceFrontPage(
          userName: widget.userName,
          userId: widget.userId,
          userDept: widget.userDept),
    );
  }
}

// class LibraryHomePage extends StatelessWidget {
//   final List<String> buttonLabels = [
//     'PREVIOUS QUESTIONS',
//     'BROWSE BOOKS',
//     'BORROWED BOOKS',
//     'E-THESIS',
//     'UPCOMING EVENTS',
//     'LIBRARY TEAM',
//     'NOTICES',
//   ];

//   LibraryHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const Icon(Icons.menu),
//         title: const Text('BetterSIS'),
//         centerTitle: true,
//         actions: [
//           const Icon(Icons.settings),
//           Stack(
//             children: <Widget>[
//               const Icon(Icons.notifications),
//               Positioned(
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(1),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   constraints: const BoxConstraints(
//                     minWidth: 12,
//                     minHeight: 12,
//                   ),
//                   child: const Text(
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
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             margin: const EdgeInsets.symmetric(vertical: 20),
//             child: Column(
//               children: buttonLabels.map((label) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           const Color(0xFFB399D4), // Button background color
//                       minimumSize: const Size(300, 50), // Button size
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () {},
//                     child: Text(
//                       label,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           const Spacer(),
//           TextButton(
//             onPressed: () {
//               // Contact Library Management action
//             },
//             child: const Text(
//               'Contact Library Management',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.blue,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
