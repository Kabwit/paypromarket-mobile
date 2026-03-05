import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _currentLang = 'fr';

  final _languages = [
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷', 'native': 'Français'},
    {'code': 'ln', 'name': 'Lingala', 'flag': '🇨🇩', 'native': 'Lingála'},
    {'code': 'sw', 'name': 'Swahili', 'flag': '🇨🇩', 'native': 'Kiswahili'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'native': 'English'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLang();
  }

  Future<void> _loadCurrentLang() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLang = prefs.getString('app_language') ?? 'fr';
    });
  }

  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', code);
    setState(() => _currentLang = code);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Langue changée. Redémarrez l\'app pour appliquer.'),
          backgroundColor: AppTheme.successColor,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Langue / Language'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _currentLang == lang['code'];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? const BorderSide(color: AppTheme.primaryColor, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
              title: Text(lang['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(lang['native']!, style: TextStyle(color: Colors.grey[600])),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              onTap: () => _setLanguage(lang['code']!),
            ),
          );
        },
      ),
    );
  }
}
