import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme.dart';
import '../widgets/neo_button.dart';
import '../widgets/glass_card.dart';
import 'expandable_provider_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  final Box _box = Hive.box('settings');
  bool _isObscure = true;
  String _selectedProvider = 'openai';

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: _box.get('ai_api_key', defaultValue: ''));
    _selectedProvider = _box.get('ai_provider', defaultValue: 'openai');
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _box.put('ai_api_key', _apiKeyController.text.trim());
    await _box.put('ai_provider', _selectedProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key Saved!'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Configuration',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your API Key to enable AI features like course summaries and smart suggestions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              opacity: 0.05,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Provider',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ExpandableProviderSelector(
                      selectedProvider: _selectedProvider,
                      onSelected: (value) {
                        setState(() {
                          _selectedProvider = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'API Key',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _isObscure,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'sk-...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            NeoButton(
              text: 'Save Configuration',
              onPressed: _save,
              isPrimary: true,
              isFullWidth: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
