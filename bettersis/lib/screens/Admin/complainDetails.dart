import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async'; 

class ComplainDetailsPage extends StatefulWidget {
  final VoidCallback onLogout;

  const ComplainDetailsPage({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<ComplainDetailsPage> createState() => _ComplainDetailsPageState();
}

class _ComplainDetailsPageState extends State<ComplainDetailsPage> {
  final String userDept = 'admin'; // Hard-coded for admin

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Complaint Management',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Complains').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No complaints found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final complainCount = data['complains'] ?? 0;
              final userCount = data['users'] ?? 0;
              final topicName = doc.id;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    topicName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Complaints: $complainCount | Users: $userCount',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TopicComplaintsPage(
                          topicId: topicName,
                          userDept: userDept,
                          onLogout: widget.onLogout,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TopicComplaintsPage extends StatefulWidget {
  final String topicId;
  final String userDept;
  final VoidCallback onLogout;

  const TopicComplaintsPage({
    Key? key,
    required this.topicId,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<TopicComplaintsPage> createState() => _TopicComplaintsPageState();
}

class _TopicComplaintsPageState extends State<TopicComplaintsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allComplaints = [];
  List<Map<String, dynamic>> _filteredComplaints = [];
  String _errorMessage = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _loadingMore = false;
  final ScrollController _scrollController = ScrollController();

  // Batch size for loading complaints
  final int _batchSize = 15;
  int _currentBatchIndex = 0;
  bool _hasMoreData = true;

  // Cache for document IDs
  Map<String, String> _idCache = {};

  // Add these variables at the top of _TopicComplaintsPageState
  Timer? _searchDebounce;
  Map<String, List<Map<String, dynamic>>> _searchCache = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialComplaints();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500 &&
        !_loadingMore &&
        _hasMoreData) {
      _loadMoreComplaints();
    }
  }

  // Replace the existing _onSearchChanged method with this optimized version
  void _onSearchChanged() {
    // Cancel previous timer if it exists
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce!.cancel();
    }

    // Set up debounce to prevent excessive filtering while typing
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim();

      // Check if we already have this search cached
      if (_searchCache.containsKey(query)) {
        setState(() {
          _filteredComplaints = _searchCache[query]!;
        });
        return;
      }

      // Perform the search
      _performOptimizedSearch(query);
    });
  }

  // New method for optimized search
  Future<void> _performOptimizedSearch(String query) async {
    // Avoid UI jank during search by setting a flag
    setState(() {
      _isSearching = true;
    });

    // Run search in a microtask to keep UI responsive
    await Future.microtask(() {
      final searchQuery = query.toLowerCase();
      List<Map<String, dynamic>> results;

      if (searchQuery.isEmpty) {
        results = List.from(_allComplaints);
      } else {
        // Create search index for faster matching
        Map<String, List<int>> searchIndex = {};

        // Helper function to add words to index
        void addToIndex(String text, int complaintIndex) {
          if (text.isEmpty) return;

          // Split by non-alphanumeric characters and index each word
          final words = text
              .toLowerCase()
              .split(RegExp(r'[^\w]'))
              .where((word) => word.isNotEmpty);

          for (final word in words) {
            searchIndex.putIfAbsent(word, () => []);
            if (!searchIndex[word]!.contains(complaintIndex)) {
              searchIndex[word]!.add(complaintIndex);
            }
          }
        }

        // Build search index for faster matching
        for (int i = 0; i < _allComplaints.length; i++) {
          final complaint = _allComplaints[i];
          // Index user ID
          addToIndex(complaint['userId']?.toString() ?? '', i);
          // Index issue text
          addToIndex(complaint['issue']?.toString() ?? '', i);
          // Index subject for Others topic
          if (widget.topicId == 'Others') {
            addToIndex(complaint['subject']?.toString() ?? '', i);
          }
        }

        // Find matching complaint indices from the index
        Set<int> matchIndices = {};

        // Split search query into words
        final searchWords = searchQuery
            .split(RegExp(r'[^\w]'))
            .where((word) => word.isNotEmpty)
            .toList();

        if (searchWords.isEmpty) {
          // If no valid search words, search the entire string
          for (int i = 0; i < _allComplaints.length; i++) {
            final complaint = _allComplaints[i];
            final userId = complaint['userId']?.toString().toLowerCase() ?? '';
            final issue = complaint['issue']?.toString().toLowerCase() ?? '';

            if (userId.contains(searchQuery) || issue.contains(searchQuery)) {
              matchIndices.add(i);
              continue;
            }

            if (widget.topicId == 'Others') {
              final subject =
                  complaint['subject']?.toString().toLowerCase() ?? '';
              if (subject.contains(searchQuery)) {
                matchIndices.add(i);
              }
            }
          }
        } else {
          // Use indexed search for word matching
          for (final word in searchWords) {
            // Look for words that start with our search term
            searchIndex.forEach((indexWord, indices) {
              if (indexWord.startsWith(word)) {
                matchIndices.addAll(indices);
              }
            });
          }
        }

        // Get the filtered complaints from matched indices
        results = matchIndices.map((i) => _allComplaints[i]).toList();

        // Sort results for consistency
        results.sort((a, b) {
          final aUserId = a['userId'] as String? ?? '';
          final bUserId = b['userId'] as String? ?? '';

          int userCompare = aUserId.compareTo(bUserId);
          if (userCompare != 0) return userCompare;

          final aTimestamp = a['timestamp'] as Timestamp?;
          final bTimestamp = b['timestamp'] as Timestamp?;

          if (aTimestamp == null && bTimestamp == null) return 0;
          if (aTimestamp == null) return 1;
          if (bTimestamp == null) return -1;

          return bTimestamp.compareTo(aTimestamp);
        });
      }

      // Cache the search results
      _searchCache[query] = results;

      if (mounted) {
        setState(() {
          _searchQuery = query;
          _filteredComplaints = results;
          _isSearching = false;
        });
      }
    });
  }

  void _filterComplaints(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredComplaints = List.from(_allComplaints);
      } else {
        _filteredComplaints = _allComplaints.where((complaint) {
          // Check user ID
          final userId = complaint['userId']?.toString().toLowerCase() ?? '';
          if (userId.contains(_searchQuery)) return true;

          // Check complaint text
          final issue = complaint['issue']?.toString().toLowerCase() ?? '';
          if (issue.contains(_searchQuery)) return true;

          // Check subject for "Others" topic
          if (widget.topicId == 'Others') {
            final subject =
                complaint['subject']?.toString().toLowerCase() ?? '';
            if (subject.contains(_searchQuery)) return true;
          }

          return false;
        }).toList();
      }
    });
  }

  Future<void> _loadInitialComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _currentBatchIndex = 0;
      _hasMoreData = true;
    });

    try {
      // Get document IDs from Users collection only once
      await _loadUserIDs();
      await _loadComplaintBatch();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading complaints: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreComplaints() async {
    if (_loadingMore || !_hasMoreData) return;

    setState(() {
      _loadingMore = true;
    });

    await _loadComplaintBatch();

    if (mounted) {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  // Load IDs from Users collection - only do this once
  Future<void> _loadUserIDs() async {
    _idCache.clear();
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      for (var doc in usersSnapshot.docs) {
        final docId = doc.id;
        final userData = doc.data();
        final internalId = userData['id'] ?? docId;
        _idCache[internalId] = docId;
      }
    } catch (e) {
      // Continue even if this fails
    }
  }

  // Load complaints in batches
  Future<void> _loadComplaintBatch() async {
    if (!_hasMoreData) return;

    try {
      // Skip if topic doesn't exist
      if (_currentBatchIndex == 0) {
        DocumentReference topicRef = FirebaseFirestore.instance
            .collection('Complains')
            .doc(widget.topicId);
        DocumentSnapshot topicDoc = await topicRef.get();
        if (!topicDoc.exists) {
          setState(() {
            _errorMessage = 'Topic does not exist';
            _isLoading = false;
          });
          return;
        }
      }

      // Get a subset of IDs to check for this batch
      List<String> allIds = _idCache.keys.toList();
      int startIndex = _currentBatchIndex * _batchSize;
      int endIndex = startIndex + _batchSize;
      if (endIndex >= allIds.length) {
        endIndex = allIds.length;
        _hasMoreData = false;
      }

      List<String> batchIds = allIds.sublist(startIndex, endIndex);
      List<Map<String, dynamic>> batchComplaints = [];

      // Load complaints for this batch of IDs
      await Future.wait(batchIds.map((id) async {
        try {
          final complaintsQuery = await FirebaseFirestore.instance
              .collection('Complains')
              .doc(widget.topicId)
              .collection(id)
              .get();

          for (var doc in complaintsQuery.docs) {
            final complaintData = doc.data();
            batchComplaints.add({
              'docId': doc.id,
              'userId': id,
              'docUserId': _idCache[id],
              ...complaintData,
            });
          }
        } catch (e) {
          // Skip errors for individual user lookups
        }
      }));

      // Sort new batch
      batchComplaints.sort((a, b) {
        final aUserId = a['userId'] as String? ?? '';
        final bUserId = b['userId'] as String? ?? '';

        int userCompare = aUserId.compareTo(bUserId);
        if (userCompare != 0) return userCompare;

        final aTimestamp = a['timestamp'] as Timestamp?;
        final bTimestamp = b['timestamp'] as Timestamp?;

        if (aTimestamp == null && bTimestamp == null) return 0;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;

        return bTimestamp.compareTo(aTimestamp);
      });

      if (!mounted) return;

      setState(() {
        _currentBatchIndex++;
        _allComplaints.addAll(batchComplaints);
        _filterComplaints(_searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error loading complaints: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'All Complaints - ${widget.topicId}',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView(theme)
              : _allComplaints.isEmpty
                  ? _buildNoComplaintsView(theme)
                  : _buildComplaintsView(),
    );
  }

  Widget _buildComplaintsView() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search complaints...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Row(
            children: [
              Text(
                'Found ${_filteredComplaints.length} complaints',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  'for "$_searchQuery"',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              if (_isSearching)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              else if (_loadingMore)
                Container(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
            ],
          ),
        ),

        // Complaint list
        Expanded(
          child: _buildComplaintsListView(),
        ),
      ],
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialComplaints,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoComplaintsView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No complaints found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No complaints found for the topic "${widget.topicId}"',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialComplaints,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredComplaints.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index == _filteredComplaints.length) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }

        final complaint = _filteredComplaints[index];
        final issue = complaint['issue'] ?? 'No description';
        final subject = complaint['subject'] ?? widget.topicId;
        final userId = complaint['userId'] ?? 'Unknown';
        final timestamp = complaint['timestamp'] as Timestamp?;
        final date = timestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(
                timestamp.millisecondsSinceEpoch)
            : DateTime.now();

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with User ID and timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User ID with a tag-like appearance
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Text(
                        'Student ID: $userId',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    // Timestamp
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (widget.topicId == 'Others') ...[
                  Text(
                    'Subject: $subject',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  issue,
                  // Highlight search terms if needed
                  style: _searchQuery.isNotEmpty &&
                          issue
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase())
                      ? TextStyle(backgroundColor: Colors.yellow[100])
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
