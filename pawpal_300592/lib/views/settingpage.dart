import 'package:flutter/material.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/shared/mydrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  final User? user;

  const SettingPage({super.key, required this.user});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String selectedTheme = 'system'; // system | light | dark
  String selectedLanguage = 'en'; // en | ms
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  // Load saved preferences from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTheme = prefs.getString('theme') ?? 'system';
      selectedLanguage = prefs.getString('language') ?? 'en';
      isLoading = false;
    });
  }

  // Save Theme preference
  Future<void> saveTheme(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', value);
    setState(() => selectedTheme = value);

    // Optional: You could trigger a theme change globally here
    _showToast("Theme updated");
  }

  // Save Language preference
  Future<void> saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    setState(() => selectedLanguage = value);

    _showToast("Language updated");
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 500
                    ? 500
                    : double.infinity,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionTitle("Appearance"),
                    _card(
                      children: [
                        _radioTile(
                          title: "System Default",
                          value: 'system',
                          groupValue: selectedTheme,
                          onChanged: saveTheme,
                        ),
                        _radioTile(
                          title: "Light Mode",
                          value: 'light',
                          groupValue: selectedTheme,
                          onChanged: saveTheme,
                        ),
                        _radioTile(
                          title: "Dark Mode",
                          value: 'dark',
                          groupValue: selectedTheme,
                          onChanged: saveTheme,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle("Language"),
                    _card(
                      children: [
                        _selectTile(
                          title: "English",
                          selected: selectedLanguage == 'en',
                          onTap: () => saveLanguage('en'),
                        ),
                        _selectTile(
                          title: "Bahasa Melayu",
                          selected: selectedLanguage == 'ms',
                          onTap: () => saveLanguage('ms'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        "PawPal v0.1b",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  // ---------- UI helpers ----------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _radioTile({
    required String title,
    required String value,
    required String groupValue,
    required Function(String) onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      activeColor: const Color(0xFF1F3C88),
      groupValue: groupValue,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }

  Widget _selectTile({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: selected
          ? const Icon(Icons.check, color: Color(0xFF1F3C88))
          : null,
      onTap: onTap,
    );
  }
}
