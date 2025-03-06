import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bettersis/modules/loading_spinner.dart';

class InternetUsageHistory extends StatefulWidget {
  final VoidCallback onLogout;

  const InternetUsageHistory({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  _InternetUsageHistoryState createState() => _InternetUsageHistoryState();
}

class _InternetUsageHistoryState extends State<InternetUsageHistory> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _exceededUsers = [];
  final int _maxLimit = 12000; // Maximum internet usage limit in minutes

  @override
  void initState() {
    super.initState();
    _loadExceededUsers();
  }

  Future<void> _loadExceededUsers() async {
    setState(() => _isLoading = true);
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Internet')
          .get();

      final exceededUsers = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String totalUsage = data['totalUsage'] ?? '0';
        final int usageMinutes = int.parse(totalUsage.replaceAll(',', ''));

        if (usageMinutes > _maxLimit) {
          // Get user details from Users collection
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(doc.id)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            exceededUsers.add({
              'id': doc.id,
              'name': userData['name'] ?? 'Unknown',
              'department': userData['department'] ?? 'Unknown',
              'totalUsage': totalUsage,
              'usageHistory': data['usageHistory'] ?? [],
            });
          }
        }
      }

      setState(() {
        _exceededUsers = exceededUsers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading exceeded users: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showUsageDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getTheme('admin').primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Usage History - ${user['name']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: (user['usageHistory'] as List).length,
                  itemBuilder: (context, index) {
                    final usage = user['usageHistory'][index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(usage['location']),
                        subtitle: Text('${usage['start']} - ${usage['end']}'),
                        trailing: Text(
                          '${usage['duration']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme('admin');

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Internet Usage History',
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadExceededUsers,
            child: _exceededUsers.isEmpty && !_isLoading
                ? const Center(
                    child: Text(
                      'No users have exceeded the internet limit',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exceededUsers.length,
                    itemBuilder: (context, index) {
                      final user = _exceededUsers[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(user['name']),
                          subtitle: Text(
                            'ID: ${user['id']}\nDepartment: ${user['department']}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${user['totalUsage']} mins',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                'Limit: $_maxLimit mins',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showUsageDetails(user),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading) const LoadingSpinner(),
        ],
      ),
    );
  }
} 