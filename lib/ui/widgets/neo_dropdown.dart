import 'package:flutter/material.dart';
import '../../core/theme.dart';

class NeoDropdownEntry<T> {
  final T value;
  final String label;

  const NeoDropdownEntry({required this.value, required this.label});
}

class NeoDropdown<T> extends StatefulWidget {
  final T? selectedValue;
  final List<NeoDropdownEntry<T>> entries;
  final ValueChanged<T> onSelected;
  final String hintText;

  const NeoDropdown({
    super.key,
    required this.selectedValue,
    required this.entries,
    required this.onSelected,
    this.hintText = 'Select Option',
  });

  @override
  State<NeoDropdown<T>> createState() => _NeoDropdownState<T>();
}

class _NeoDropdownState<T> extends State<NeoDropdown<T>>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  List<NeoDropdownEntry<T>> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _filteredEntries = widget.entries;
    
    _updateSearchText();

    _searchController.addListener(_onSearchChanged);
  }

  void _updateSearchText() {
    if (widget.selectedValue != null) {
      final selectedEntry = widget.entries.firstWhere(
        (e) => e.value == widget.selectedValue,
        orElse: () => NeoDropdownEntry(value: widget.selectedValue as T, label: ''),
      );
      _searchController.text = selectedEntry.label;
    } else {
      _searchController.text = widget.hintText;
    }
  }

  @override
  void didUpdateWidget(covariant NeoDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue && !_isMenuOpen) {
       _updateSearchText();
    }
    // Update filtered entries if the source list changes
    if (widget.entries != oldWidget.entries) {
      _filteredEntries = widget.entries;
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    
    // If not open, don't filter (we are just showing the selected value)
    if (!_isMenuOpen) return;

    setState(() {
      _filteredEntries = widget.entries.where((entry) {
        return entry.label.toLowerCase().contains(query);
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
        _filteredEntries = widget.entries;
        _searchFocusNode.requestFocus();
      } else {
        // Closing: Restore selected provider text, unfocus
        _updateSearchText();
        _searchFocusNode.unfocus();
      }
    });
  }

  void _selectItem(T value) {
    widget.onSelected(value);
    _toggleMenu(); // Close menu
  }

  @override
  Widget build(BuildContext context) {
    final isSelectedValueNull = widget.selectedValue == null;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), 
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(
                        color: (isSelectedValueNull && !_isMenuOpen) 
                            ? Colors.white.withValues(alpha: 0.6) 
                            : Colors.white,
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
                      readOnly: false, // Keep editable for search
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
                itemCount: _filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = _filteredEntries[index];
                  final isSelected = entry.value == widget.selectedValue;

                  return InkWell(
                    onTap: () => _selectItem(entry.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: isSelected ? AppTheme.accent.withValues(alpha: 0.1) : null,
                      child: Text(
                        entry.label,
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
