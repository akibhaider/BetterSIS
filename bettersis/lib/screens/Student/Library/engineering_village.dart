import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:bettersis/modules/show_message.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController _searchController = TextEditingController();
  bool hasSearched = false;
  List<Map<String, String>> filteredBooks = [];
  List<Map<String, String>> books = [];
  bool _isLoading = true;

  Map<String, String> bookImageUrls = {};

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('library_books')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        books = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'title': data['title'] as String,
            'author': data['author'] as String,
            'edition': data['edition'] as String,
            'category': data['category'] as String,
            'imagePath': data['imagePath'] as String,
            'imageUrl': data['imageUrl'] as String,
          };
        }).toList();
        filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
        title: 'Engineering Village',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: SizedBox(
                              width: 100,
                              child: Image.network(
                                book['imageUrl'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.book, size: 40),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              ),
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
                              onPressed: () async {
                                if (await _requestStoragePermission()) {
                                  downloadBook(book);
                                } else {
                                  ShowMessage.error(context, 'Storage permission is required to download files');
                                }
                              },
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
      // Request storage permission
      if (await _requestStoragePermission()) {
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

        final fileName = '${book['title']}_${book['author']}.jpg'.replaceAll(RegExp(r'[^\w\s.-]'), '_');
        final filePath = '${customPath.path}/$fileName';

        // Download the image
        final response = await http.get(Uri.parse(book['imageUrl']!));
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        ShowMessage.success(context, 'Book cover downloaded to Downloads/BetterSIS/Books');
      }
    } catch (e) {
      print('Error downloading book: $e');
      ShowMessage.error(context, 'Failed to download book cover');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true; // For iOS, return true as we handle it differently
  }
}
