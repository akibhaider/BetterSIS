import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bettersis/utils/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  final String userId;
  final String userDept;
  final VoidCallback onLogout;

  const SettingsPage({
    super.key,
    required this.userId,
    required this.userDept,
    required this.onLogout,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _allowNotifications;
  late bool _isSetLimit;
  late int _limit;
  late TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _allowNotifications = settingsProvider.allowNotifications;
    _isSetLimit = settingsProvider.isSetLimit;
    _limit = settingsProvider.getLimit(widget.userId);
    _limitController = TextEditingController(text: _limit.toString());
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.setAllowNotifications(_allowNotifications);
    settingsProvider.setIsSetLimit(_isSetLimit);
    settingsProvider.setLimit(_limit, widget.userId);
    FocusScope.of(context).unfocus();
  }

  void _cancelChanges() {
    setState(() {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      _allowNotifications = settingsProvider.allowNotifications;
      _isSetLimit = settingsProvider.isSetLimit;
      _limit = settingsProvider.limit;
      _limitController.text = _limit.toString();
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Settings',
      ),
      body: SingleChildScrollView(
        // Wrap the body with SingleChildScrollView
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingTile(
              title: 'Allow Notifications',
              icon: Icons.notifications_active,
              value: _allowNotifications,
              onChanged: (value) {
                setState(() {
                  _allowNotifications = value;
                  if (!value) {
                    _isSetLimit = false;
                  }
                });
              },
              theme: theme,
            ),
            Divider(),
            _buildSettingTile(
              title: 'Set Limit',
              icon: Icons.speed,
              value: _isSetLimit,
              onChanged: _allowNotifications
                  ? (value) {
                      setState(() {
                        _isSetLimit = value;
                      });
                    }
                  : null,
              theme: theme,
              isEnabled: _allowNotifications,
            ),
            Divider(),
            const SizedBox(height: 16),
            Text(
              'Limit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _allowNotifications && _isSetLimit
                    ? theme.primaryColor
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _limitController,
              decoration: InputDecoration(
                hintText: 'Enter limit (1 - 12000)',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: _allowNotifications && _isSetLimit
                    ? Colors.white
                    : Colors.grey.shade300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: theme.primaryColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
                enabled: _allowNotifications && _isSetLimit,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int? newLimit = int.tryParse(value);
                if (newLimit != null && newLimit >= 1 && newLimit <= 12000) {
                  _limit = newLimit;
                }
              },
            ),
            const SizedBox(height: 16),
            Divider(),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                  onPressed: _saveSettings,
                  child: const Text('Save', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                  onPressed: _cancelChanges,
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool)? onChanged,
    required ThemeData theme,
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading:
            Icon(icon, color: isEnabled ? theme.primaryColor : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isEnabled ? theme.primaryColor : Colors.grey,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
          inactiveTrackColor: Colors.red.shade300,
          inactiveThumbColor: Colors.red,
        ),
      ),
    );
  }
}
