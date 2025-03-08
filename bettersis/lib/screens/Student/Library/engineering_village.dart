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
  bool _isLoading = true;
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> filteredBooks = [];
  String? _selectedDepartment;
  String? _filterDepartment;

  final List<String> departments = ['cse', 'eee', 'cee', 'mpe', 'btm'];

  Map<String, Color> deptColors = {
    'cse': Colors.blue.shade700,
    'eee': Colors.amber.shade700,
    'cee': Colors.green.shade700,
    'mpe': Colors.red.shade700,
    'btm': Colors.purple.shade700,
  };

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
            'id': doc.id,
            'title': data['title'] as String,
            'author': data['author'] as String,
            'edition': data['edition'] as String,
            'category': data['category'] as String,
            'imageUrl': data['imageUrl'] as String,
            'departments': (data['departments'] as List<dynamic>?)?.cast<String>() ?? [],
            'url': data['url'] as String?,
          };
        }).toList();
        filteredBooks = List.from(books);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() => _isLoading = false);
    }
  }

  void _searchBooks(String query) {
    setState(() {
      if (query.isEmpty && _filterDepartment == null) {
        filteredBooks = books;
      } else {
        filteredBooks = books.where((book) {
          bool matchesSearch = true;
          if (query.isNotEmpty) {
            final titleMatch = book['title'].toString().toLowerCase().contains(query.toLowerCase());
            final authorMatch = book['author'].toString().toLowerCase().contains(query.toLowerCase());
            final categoryMatch = book['category'].toString().toLowerCase().contains(query.toLowerCase());
            matchesSearch = titleMatch || authorMatch || categoryMatch;
          }

          bool matchesDepartment = true;
          if (_filterDepartment != null) {
            matchesDepartment = (book['departments'] as List<String>).contains(_filterDepartment);
          }

          return matchesSearch && matchesDepartment;
        }).toList();
      }
    });
  }

  void _showDepartmentFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Department'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Show All'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _filterDepartment,
                  onChanged: (value) {
                    setState(() {
                      _filterDepartment = value;
                      Navigator.pop(context);
                      _searchBooks(_searchController.text);
                    });
                  },
                ),
              ),
              ...departments.map((dept) => ListTile(
                title: Text(dept.toUpperCase()),
                leading: Radio<String?>(
                  value: dept,
                  groupValue: _filterDepartment,
                  onChanged: (value) {
                    setState(() {
                      _filterDepartment = value;
                      Navigator.pop(context);
                      _searchBooks(_searchController.text);
                    });
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Engineering Village',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search and Filter Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchBooks('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _searchBooks,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.filter_list),
                        if (_filterDepartment != null)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 8,
                                minHeight: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _showDepartmentFilterDialog,
                    tooltip: 'Filter by Department',
                  ),
                ),
              ],
            ),

            // Active Filter Indicator
            if (_filterDepartment != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filtered by: ${_filterDepartment!.toUpperCase()}',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.close, size: 16, color: theme.primaryColor),
                      onPressed: () {
                        setState(() {
                          _filterDepartment = null;
                          _searchBooks(_searchController.text);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Book List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredBooks.isEmpty
                      ? const Center(child: Text('No books found'))
                      : ListView.builder(
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primaryColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      book['imageUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.book),
                                    ),
                                  ),
                                ),
                                title: Container(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    book['title'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                subtitle: Container(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Author: ${book['author']}'),
                                      const SizedBox(height: 4),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (String dept in book['departments'])
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: deptColors[dept],
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.bookmark,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Container(
                                  width: 48,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minHeight: 36,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'download') {
                                            _downloadBook(book);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'download',
                                            child: Row(
                                              children: [
                                                Icon(Icons.download),
                                                SizedBox(width: 8),
                                                Text('Download'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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

  Future<void> _downloadBook(Map<String, dynamic> book) async {
    if (book['url'] == null) {
      ShowMessage.error(context, 'No download URL available for this book');
      return;
    }

    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ShowMessage.error(context, 'Storage permission is required to download files');
        return;
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ShowMessage.error(context, 'Failed to access storage');
        return;
      }

      final customPath = Directory(
          '${directory.parent.parent.parent.parent.path}/Download/BetterSIS/Engineering Village');

      if (!await customPath.exists()) {
        await customPath.create(recursive: true);
      }

      final safeTitle = book['title'].toString().replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
      final safeAuthor = book['author'].toString().replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
      final filePath = '${customPath.path}/${safeTitle}_${safeAuthor}.pdf';

      final response = await http.get(Uri.parse(book['url']));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ShowMessage.success(context, 'Book downloaded successfully');
    } catch (e) {
      print('Error downloading book: $e');
      ShowMessage.error(context, 'Failed to download book');
    }
  }
}
