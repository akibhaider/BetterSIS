import 'package:flutter/material.dart';

void main() {
  runApp(LibraryApp());
}

class LibraryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterSIS Library',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LibraryHomePage(),
    );
  }
}

class LibraryHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: Text('BetterSIS'),
        centerTitle: true,
        actions: [
          Icon(Icons.settings),
          Stack(
            children: <Widget>[
              Icon(Icons.notifications),
              Positioned(
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
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
              MaterialPageRoute(builder: (context) => BrowseBooksPanel()),
            );
          },
          child: Text('BROWSE BOOKS'),
        ),
      ),
    );
  }
}

class BrowseBooksPanel extends StatefulWidget {
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
        title: Text('Browse Books'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Catalog') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Catalog'),
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
                        child: Text('Close'),
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
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
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
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
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
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: Text(
                        'No book selected. Please search.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            // Download Button
            ElevatedButton.icon(
              onPressed: selectedBook.isNotEmpty
                  ? () {
                      // Handle download action
                    }
                  : null,
              icon: Icon(Icons.download),
              label: Text('Download'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                minimumSize: Size(double.infinity, 50),
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

