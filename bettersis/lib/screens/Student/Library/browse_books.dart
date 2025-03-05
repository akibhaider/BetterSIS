import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:bettersis/modules/show_message.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BrowseBooksPage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const BrowseBooksPage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _BrowseBooksPageState createState() => _BrowseBooksPageState();
}

class _BrowseBooksPageState extends State<BrowseBooksPage> {
  final TextEditingController _searchController = TextEditingController();
  bool hasSearched = false;
  List<Map<String, String>> filteredBooks = [];

  final List<Map<String, String>> books = [
    {
      'title': 'Flutter for Beginners',
      'author': 'John Doe',
      'edition': '2nd Edition',
      'category': 'Programming',
      'imagePath': 'Library/Books/Programming/flutter_beginners.png'
    },
    {
      'title': 'Advanced Dart Programming',
      'author': 'Jane Smith',
      'edition': '3rd Edition',
      'category': 'Programming',
      'imagePath': 'Library/Books/Programming/advanced_dart.png'
    },
    {
      'title': 'Mobile Development with Flutter',
      'author': 'Alan Brown',
      'edition': '1st Edition',
      'category': 'Mobile Development',
      'imagePath': 'Library/Books/Mobile/flutter_mobile.png'
    },
    {
      'title': 'Software Engineering Principles',
      'author': 'Robert Martin',
      'edition': '4th Edition',
      'category': 'Software Engineering',
      'imagePath': 'Library/Books/Software/principles.png'
    },
    {
      'title': 'Database Management Systems',
      'author': 'Emily Chen',
      'edition': '5th Edition',
      'category': 'Database',
      'imagePath': 'Library/Books/Database/dbms.png'
    },
  ];

  // Add a map to store image URLs
  Map<String, String> bookImageUrls = {};

  @override
  void initState() {
    super.initState();
    filteredBooks = books;
    // Load images for all books
    for (var book in books) {
      _loadBookImage(book);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookImage(Map<String, String> book) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(book['imagePath']!);
      final url = await ref.getDownloadURL();
      setState(() {
        bookImageUrls[book['title']!] = url;
      });
    } catch (e) {
      print('Error loading image for ${book['title']}: $e');
    }
  }

  void searchBooks(String query) {
    setState(() {
      hasSearched = true;
      if (query.isEmpty) {
        filteredBooks = books;
      } else {
        filteredBooks = books.where((book) {
          final titleMatch = book['title']!.toLowerCase().contains(query.toLowerCase());
          final authorMatch = book['author']!.toLowerCase().contains(query.toLowerCase());
          final categoryMatch = book['category']!.toLowerCase().contains(query.toLowerCase());
          return titleMatch || authorMatch || categoryMatch;
        }).toList();
      }
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
        title: 'Browse Books',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: theme.primaryColor),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by title, author, or category...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      onSubmitted: (value) => searchBooks(value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => searchBooks(_searchController.text),
                    color: theme.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (hasSearched && filteredBooks.isEmpty)
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Book not found',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Book cover image
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              color: Colors.grey.shade200,
                            ),
                            child: bookImageUrls.containsKey(book['title'])
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      bookImageUrls[book['title']]!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.book, size: 40),
                                        );
                                      },
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.book, size: 40),
                                  ),
                          ),
                          // Book details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book['title']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Author: ${book['author']}",
                                    style: TextStyle(color: Colors.grey.shade800),
                                  ),
                                  Text(
                                    "Edition: ${book['edition']}",
                                    style: TextStyle(color: Colors.grey.shade800),
                                  ),
                                  Text(
                                    "Category: ${book['category']}",
                                    style: TextStyle(color: Colors.grey.shade800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Download button
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => downloadBook(book),
                              color: theme.primaryColor,
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

  Future<void> downloadBook(Map<String, String> book) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to download files')),
        );
        return;
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ShowMessage.error(context, 'Failed to access storage');
        return;
      }

      final customPath = Directory(
          '${directory.parent.parent.parent.parent.path}/Download/BetterSIS/Books');

      if (!await customPath.exists()) {
        await customPath.create(recursive: true);
      }

      final filePath = '${customPath.path}/${book['title']}.pdf';

      // Here you would normally download the actual file
      // For now, we'll just show a success message
      ShowMessage.success(context, 'Book downloaded to: $filePath');
    } catch (e) {
      print('Error downloading book: $e');
      ShowMessage.error(context, 'Failed to download book');
    }
  }
}

