import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onModeChanged;
  final Function(String?) onLanguageChanged;

  SettingsPage({required this.onModeChanged, required this.onLanguageChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  String selectedLanguage = 'English';
  String selectedTheme = 'System Default';
  bool isSettingsChanged = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      selectedTheme = prefs.getString('selectedTheme') ?? 'System Default';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (isDarkMode != prefs.getBool('isDarkMode') ||
        selectedLanguage != prefs.getString('selectedLanguage') ||
        selectedTheme != prefs.getString('selectedTheme')) {
      await prefs.setBool('isDarkMode', isDarkMode);
      await prefs.setString('selectedLanguage', selectedLanguage);
      await prefs.setString('selectedTheme', selectedTheme);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Settings'),
        content: Text('Are you sure you want to reset all settings?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isDarkMode = false;
                selectedLanguage = 'English';
                selectedTheme = 'System Default';
                isSettingsChanged = true;
              });

              widget.onModeChanged(isDarkMode);
              widget.onLanguageChanged(selectedLanguage);
              Navigator.of(context).pop();
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Reset settings',
            onPressed: _resetSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
              ),
              Divider(),

              Card(
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.dark_mode, color: Theme.of(context).iconTheme.color),
                  title: Text('Dark Mode'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                        isSettingsChanged = true;
                      });
                      widget.onModeChanged(isDarkMode);
                    },
                  ),
                ),
              ),

              Card(
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.color_lens, color: Theme.of(context).iconTheme.color),
                  title: Text('Theme'),
                  trailing: DropdownButton<String>(
                    value: selectedTheme,
                    items: ['System Default', 'Light', 'Dark']
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(value: value, child: Text(value)),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTheme = value!;
                        isSettingsChanged = true;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              Text(
                'Preferences',
                style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
              ),
              Divider(),

              Card(
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.language, color: Theme.of(context).iconTheme.color),
                  title: Text('Language'),
                  trailing: DropdownButton<String>(
                    value: selectedLanguage,
                    items: ['English', 'French', 'Arabic']
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(value: value, child: Text(value)),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                        isSettingsChanged = true;
                      });
                      widget.onLanguageChanged(selectedLanguage);
                      _saveSettings();
                    },
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Save Settings'),
                  onPressed: () {
                    if (isSettingsChanged) {
                      _saveSettings();
                      setState(() {
                        isSettingsChanged = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.015),
                    textStyle: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Locale _getLocaleFromLanguage(String language) {
  switch (language) {
    case 'French':
      return Locale('fr', 'FR');
    case 'Arabic':
      return Locale('ar', 'SA');
    default:
      return Locale('en', 'US');
  }
}