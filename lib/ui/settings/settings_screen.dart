import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme.dart';
import '../../logic/providers.dart';
import '../../logic/auth/auth_provider.dart';
import '../widgets/neo_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/neo_dropdown.dart';
import '../widgets/neo_text_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late Box _box;
  bool _isObscure = true;
  String _selectedProvider = 'openai';

  final Map<String, String> _providerLabels = {
    'openai': 'OpenAI',
    'gemini': 'Google Gemini',
    'anthropic': 'Anthropic (Claude)',
    'perplexity': 'Perplexity',
    'openrouter': 'OpenRouter',
    'deepseek': 'DeepSeek',
    'groq': 'Groq',
  };

  @override
  void initState() {
    super.initState();
    _box = ref.read(settingsBoxProvider);
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
      body: SingleChildScrollView(
        child: Padding(
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
                      NeoDropdown<String>(
                        selectedValue: _selectedProvider,
                        entries: _providerLabels.entries
                            .map((e) => NeoDropdownEntry(value: e.key, label: e.value))
                            .toList(),
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
                      NeoTextField(
                        controller: _apiKeyController,
                        obscureText: _isObscure,
                        hintText: 'sk-...',
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              NeoButton(
                text: 'Save Configuration',
                onPressed: _save,
                isPrimary: true,
                isFullWidth: true,
              ),
              const SizedBox(height: 16),
              NeoButton(
                text: 'Log Out',
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (!context.mounted) return;
                  Navigator.pop(context); // Close settings, wrapper handles redirect
                },
                isPrimary: false,
                isFullWidth: true, 
                // We could add a custom style for "danger" or red button later
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
