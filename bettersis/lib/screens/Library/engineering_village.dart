import 'package:flutter/material.dart';

class EngineeringVillagePage extends StatefulWidget {
  @override
  _EngineeringVillagePageState createState() => _EngineeringVillagePageState();
}

class _EngineeringVillagePageState extends State<EngineeringVillagePage> {
  // Sample list of books with title, author, and edition
  List<Map<String, String>> books = [
    {"title": "Advanced Engineering Mathematics", "author": "Erwin Kreyszig", "edition": "10th Edition"},
    {"title": "Introduction to Fluid Mechanics", "author": "Robert W. Fox", "edition": "8th Edition"},
    {"title": "Engineering Mechanics", "author": "J.L. Meriam", "edition": "7th Edition"},
    {"title": "Digital Design", "author": "M. Morris Mano", "edition": "5th Edition"},
    {"title": "Thermodynamics", "author": "Yunus A. Çengel", "edition": "8th Edition"},
  ];

  List<String> bookTitles = [];
  String selectedBookTitle = "";
  List<Map<String, String>> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    // Extract and sort book titles alphabetically for the dropdown list
    bookTitles = books.map((book) => book['title']!).toList();
    bookTitles.sort();
    filteredBooks = books; // Initially show all books
  }

  // Function to filter books based on selected title
  void filterBooks(String title) {
    setState(() {
      selectedBookTitle = title;
      filteredBooks = books.where((book) => book['title'] == title).toList();
    });
  }

  // Function to reset the filter to show all books
  void resetFilter() {
    setState(() {
      selectedBookTitle = "";
      filteredBooks = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            // Search TextField
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for a book...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    resetFilter();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {}, // Optional functionality for search button
            ),
          ],
        ),
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
                    color: Colors.blue.shade700,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['title']!,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Author: ${book['author']}",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Edition: ${book['edition']}",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
