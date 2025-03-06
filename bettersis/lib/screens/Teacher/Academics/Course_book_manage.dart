import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bettersis/modules/show_message.dart';

class CourseBookManagePage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const CourseBookManagePage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _CourseBookManagePageState createState() => _CourseBookManagePageState();
}

class _CourseBookManagePageState extends State<CourseBookManagePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> filteredBooks = [];
  String? _selectedDepartment;

  final List<String> departments = ['cse', 'eee', 'cee', 'mpe', 'btm'];

  Map<String, Color> deptColors = {
    'cse': Colors.blue,
    'eee': Colors.amber,
    'cee': Colors.green,
    'mpe': Colors.red,
    'btm': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _loadBooks();
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
      if (query.isEmpty) {
        filteredBooks = books;
      } else {
        filteredBooks = books.where((book) {
          final titleMatch = book['title'].toString().toLowerCase().contains(query.toLowerCase());
          final authorMatch = book['author'].toString().toLowerCase().contains(query.toLowerCase());
          final categoryMatch = book['category'].toString().toLowerCase().contains(query.toLowerCase());
          return titleMatch || authorMatch || categoryMatch;
        }).toList();
      }
    });
  }

  Future<void> _addDepartmentTag(Map<String, dynamic> book) async {
    if (_selectedDepartment == null) {
      ShowMessage.error(context, 'Please select a department');
      return;
    }

    List<String> currentDepts = List<String>.from(book['departments']);
    if (currentDepts.contains(_selectedDepartment!)) {
      ShowMessage.error(context, 'This department is already tagged');
      return;
    }

    try {
      currentDepts.add(_selectedDepartment!);
      await FirebaseFirestore.instance
          .collection('library_books')
          .doc(book['id'])
          .update({'departments': currentDepts});

      ShowMessage.success(context, 'Department tag added successfully');
      _loadBooks(); // Reload the book list
    } catch (e) {
      print('Error adding department tag: $e');
      ShowMessage.error(context, 'Failed to add department tag');
    }
  }

  Future<void> _removeDepartmentTag(Map<String, dynamic> book, String dept) async {
    try {
      List<String> currentDepts = List<String>.from(book['departments']);
      currentDepts.remove(dept);
      
      await FirebaseFirestore.instance
          .collection('library_books')
          .doc(book['id'])
          .update({'departments': currentDepts});

      ShowMessage.success(context, 'Department tag removed successfully');
      _loadBooks(); // Reload the book list
    } catch (e) {
      print('Error removing department tag: $e');
      ShowMessage.error(context, 'Failed to remove department tag');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Course Books',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Department Selection
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Department to Tag',
                border: OutlineInputBorder(),
              ),
              value: _selectedDepartment,
              items: departments.map((dept) {
                return DropdownMenuItem(
                  value: dept,
                  child: Text(dept.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDepartment = value);
              },
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Books',
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
                                title: Text(book['title']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Author: ${book['author']}'),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: [
                                        for (String dept in book['departments'])
                                          Chip(
                                            label: Text(
                                              dept.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            backgroundColor: deptColors[dept],
                                            deleteIcon: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            onDeleted: () => _removeDepartmentTag(book, dept),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.bookmark_add),
                                  onPressed: () => _addDepartmentTag(book),
                                  color: theme.primaryColor,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 