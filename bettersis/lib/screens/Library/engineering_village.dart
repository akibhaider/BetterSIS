import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';

class EngineeringVillagePage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const EngineeringVillagePage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _EngineeringVillagePageState createState() => _EngineeringVillagePageState();
}

class _EngineeringVillagePageState extends State<EngineeringVillagePage> {
  List<Map<String, String>> books = [
    {"title": "Advanced Engineering Mathematics", "author": "Erwin Kreyszig", "edition": "10th Edition"},
    {"title": "Introduction to Fluid Mechanics", "author": "Robert W. Fox", "edition": "8th Edition"},
    // Additional books...
  ];

  List<String> bookTitles = [];
  String selectedBookTitle = "";
  List<Map<String, String>> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    bookTitles = books.map((book) => book['title']!).toList();
    bookTitles.sort();
    filteredBooks = books;
  }

  void filterBooks(String title) {
    setState(() {
      selectedBookTitle = title;
      filteredBooks = books.where((book) => book['title'] == title).toList();
    });
  }

  void resetFilter() {
    setState(() {
      selectedBookTitle = "";
      filteredBooks = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Engineering Village',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedBookTitle.isEmpty ? null : selectedBookTitle,
              hint: const Text("Select a book"),
              isExpanded: true,
              items: bookTitles.map((title) {
                return DropdownMenuItem<String>(
                  value: title,
                  child: Text(title),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  filterBooks(value);
                } else {
                  resetFilter();
                }
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      title: Text(
                        book['title']!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Author: ${book['author']}", style: TextStyle(color: Colors.grey.shade800)),
                          Text("Edition: ${book['edition']}", style: TextStyle(color: Colors.grey.shade800)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'Download') {
                            // Handle download action
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'Download',
                            child: Text('Download'),
                          ),
                        ],
                        icon: Icon(Icons.more_vert, color: theme.secondaryHeaderColor),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
