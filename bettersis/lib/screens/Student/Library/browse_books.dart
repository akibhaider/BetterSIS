import 'package:flutter/material.dart';

void main() {
  runApp(const LibraryApp());
}


class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterSIS Library',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LibraryHomePage(),
    );
  }
}

class LibraryHomePage extends StatelessWidget {
  const LibraryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text('BetterSIS'),
        centerTitle: true,
        actions: [
          const Icon(Icons.settings),
          Stack(
            children: <Widget>[
              const Icon(Icons.notifications),
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BrowseBooksPanel()),
            );
          },
          child: const Text('BROWSE BOOKS'),
        ),
      ),
    );
  }
}

class BrowseBooksPanel extends StatefulWidget {
  const BrowseBooksPanel({super.key});

  @override
  _BrowseBooksPanelState createState() => _BrowseBooksPanelState();
}

class _BrowseBooksPanelState extends State<BrowseBooksPanel> {
  String selectedBook = '';
  String bookNameQuery = '';
  String authorNameQuery = '';

  List<Map<String, String>> books = [
    {'name': 'Flutter for Beginners', 'author': 'John Doe'},
    {'name': 'Advanced Dart', 'author': 'Jane Smith'},
    {'name': 'Mobile Development with Flutter', 'author': 'Alan Brown'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Books'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Catalog') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Catalog'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: books.map((book) {
                        return ListTile(
                          title: Text(book['name']!),
                          subtitle: Text('Author: ${book['author']}'),
                        );
                      }).toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Catalog'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search by Book Name
            TextField(
              onChanged: (value) {
                setState(() {
                  bookNameQuery = value;
                  _searchBooks();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by Book Name',
                prefixIcon: const Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Search by Author Name
            TextField(
              onChanged: (value) {
                setState(() {
                  authorNameQuery = value;
                  _searchBooks();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by Author',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Book Preview
            selectedBook.isNotEmpty
                ? Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Preview: $selectedBook',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                : const Expanded(
                    child: Center(
                      child: Text(
                        'No book selected. Please search.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            // Download Button
            ElevatedButton.icon(
              onPressed: selectedBook.isNotEmpty
                  ? () {
                      // Handle download action
                    }
                  : null,
              icon: const Icon(Icons.download),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Use backgroundColor instead of primary
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search books based on input
  void _searchBooks() {
    setState(() {
      selectedBook = '';
      for (var book in books) {
        if (book['name']!
                .toLowerCase()
                .contains(bookNameQuery.toLowerCase()) &&
            book['author']!
                .toLowerCase()
                .contains(authorNameQuery.toLowerCase())) {
          selectedBook = book['name']!;
          break;
        }
      }
    });
  }
}

