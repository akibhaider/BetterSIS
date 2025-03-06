import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bettersis/modules/show_message.dart';

class RemoveBookPage extends StatefulWidget {
  final VoidCallback onLogout;

  const RemoveBookPage({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  _RemoveBookPageState createState() => _RemoveBookPageState();
}

class _RemoveBookPageState extends State<RemoveBookPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> filteredBooks = [];

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
        books = snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList();
        filteredBooks = List.from(books);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _deleteBook(Map<String, dynamic> book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${book['title']}"?\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('library_books')
          .doc(book['id'])
          .delete();

      // Delete from Storage
      final storageRef = FirebaseStorage.instance.ref().child(book['imagePath']);
      await storageRef.delete();

      ShowMessage.success(context, 'Book deleted successfully');
      
      // Reload the book list
      await _loadBooks();
    } catch (e) {
      print('Error deleting book: $e');
      ShowMessage.error(context, 'Failed to delete book');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme('admin');

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Remove Books',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                                subtitle: Text(
                                  'Author: ${book['author']}\nCategory: ${book['category']}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  onPressed: () => _deleteBook(book),
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