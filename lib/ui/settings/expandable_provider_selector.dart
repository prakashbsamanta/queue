import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ExpandableProviderSelector extends StatefulWidget {
  final String selectedProvider;
  final ValueChanged<String> onSelected;

  const ExpandableProviderSelector({
    super.key,
    required this.selectedProvider,
    required this.onSelected,
  });

  @override
  State<ExpandableProviderSelector> createState() => _ExpandableProviderSelectorState();
}

class _ExpandableProviderSelectorState extends State<ExpandableProviderSelector>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  final Map<String, String> _allProviders = {
    'openai': 'OpenAI',
    'gemini': 'Google Gemini',
    'anthropic': 'Anthropic (Claude)',
    'perplexity': 'Perplexity',
    'openrouter': 'OpenRouter',
    'deepseek': 'DeepSeek',
    'groq': 'Groq',
  };

  List<String> _filteredProviderKeys = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _filteredProviderKeys = _allProviders.keys.toList();
    
    // Set initial text to selected provider label ONLY if not opening
    _updateSearchText();

    _searchController.addListener(_onSearchChanged);
  }

  void _updateSearchText() {
    final label = _allProviders[widget.selectedProvider] ?? 'Select Provider';
    _searchController.text = label;
  }

  @override
  void didUpdateWidget(covariant ExpandableProviderSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProvider != oldWidget.selectedProvider && !_isMenuOpen) {
       _updateSearchText();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    
    // If not open, don't filter (we are just showing the selected value)
    if (!_isMenuOpen) return;

    setState(() {
      _filteredProviderKeys = _allProviders.keys.where((key) {
        final label = _allProviders[key]!.toLowerCase();
        return label.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        // Opening: Clear text to allow search, request focus
        _searchController.clear();
        _filteredProviderKeys = _allProviders.keys.toList();
        _searchFocusNode.requestFocus();
      } else {
        // Closing: Restore selected provider text, unfocus
        _updateSearchText();
        _searchFocusNode.unfocus();
      }
    });
  }

  void _selectProvider(String key) {
    widget.onSelected(key);
    _toggleMenu(); // Close menu
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isMenuOpen ? AppTheme.accent : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (Search Field + Icon)
          InkWell(
            onTap: _toggleMenu,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Match previous padding
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onTap: () {
                        if (!_isMenuOpen) {
                          _toggleMenu();
                        }
                      },
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isMenuOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.accent),
                  ),
                ],
              ),
            ),
          ),
          
          // Body (List of Options)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              constraints: _isMenuOpen 
                  ? const BoxConstraints(maxHeight: 200) 
                  : const BoxConstraints(maxHeight: 0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredProviderKeys.length,
                itemBuilder: (context, index) {
                  final key = _filteredProviderKeys[index];
                  final label = _allProviders[key]!;
                  final isSelected = key == widget.selectedProvider;

                  return InkWell(
                    onTap: () => _selectProvider(key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: isSelected ? AppTheme.accent.withValues(alpha: 0.1) : null,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? AppTheme.accent : Colors.white.withValues(alpha: 0.7),
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
