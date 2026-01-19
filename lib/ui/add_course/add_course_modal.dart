import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../logic/providers.dart';
import '../../logic/add_course_logic.dart';
import '../../core/theme.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_dropdown.dart';
import '../widgets/neo_text_field.dart';
import '../widgets/neo_loading.dart';
import '../widgets/neo_error.dart';

class AddCourseModal extends ConsumerStatefulWidget {
  const AddCourseModal({super.key});

  @override
  ConsumerState<AddCourseModal> createState() => _AddCourseModalState();
}

class _AddCourseModalState extends ConsumerState<AddCourseModal> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _addToExisting = false;
  String? _selectedCourseId;

  @override // Dispose controller
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final input = _urlController.text.trim();
      final isYouTube = input.contains('youtube.com') || input.contains('youtu.be');

      if (_addToExisting) {
         if (_selectedCourseId == null) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Please select a course')),
           );
           return;
         }
         
         // Determine type
         String type = 'text';
         if (isYouTube) {
           type = 'youtube';
         } else if (input.startsWith('http')) {
           type = 'url';
         }
         
         await ref.read(addCourseLogicProvider.notifier).addToExistingCourse(_selectedCourseId!, input, type);
         
      } else {
        // Create New
        if (isYouTube) {
           await ref.read(addCourseLogicProvider.notifier).addCourseFromUrl(input);
        } else {
           await ref.read(addCourseLogicProvider.notifier).addCourseByName(input);
        }
      }

      if (mounted && !ref.read(addCourseLogicProvider).hasError) {
           Navigator.pop(context);
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(_addToExisting ? 'Resource Added' : 'Course Created')),
           );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state to show errors or loading
    final addCourseState = ref.watch(addCourseLogicProvider);
    final allCourses = ref.watch(allCoursesProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Knowledge Source',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            
            // Toggle
            if (allCourses.hasValue && allCourses.value!.isNotEmpty)
            Row(
              children: [
                Switch(
                  value: _addToExisting, 
                  activeThumbColor: AppTheme.accent,
                  onChanged: (val) {
                    setState(() {
                      _addToExisting = val;
                      if (!val) _selectedCourseId = null;
                    });
                  }
                ),
                Text('Add to Existing Course', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            
            const SizedBox(height: 10),

            // Dropdown
            if (_addToExisting)
                allCourses.when(
                  data: (courses) => Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NeoDropdown<String>(
                      selectedValue: _selectedCourseId,
                      hintText: 'Select Course',
                      entries: courses.map((c) => NeoDropdownEntry(
                        value: c.id,
                        label: c.title,
                      )).toList(),
                      onSelected: (val) => setState(() => _selectedCourseId = val),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                  error: (_,__) => const SizedBox.shrink(),
                ),

            if (_addToExisting) const SizedBox(height: 10),

            NeoTextField(
              controller: _urlController,
              hintText: _addToExisting ? 'Paste Link or type Text' : 'Paste YouTube URL or Course Name',
              prefixIcon: const Icon(Icons.edit_note, color: AppTheme.accent),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            addCourseState.when(
              data: (_) => SizedBox(
                width: double.infinity,
                child: NeoButton(
                  text: _addToExisting ? 'Add Resource' : 'Create Course',
                  onPressed: _submit,
                  icon: _addToExisting ? Icons.add_link : Icons.library_add,
                ),
              ),
              loading: () => const SizedBox(
                height: 100,
                child: NeoLoading(message: 'Processing...'),
              ),
              error: (err, stack) => NeoError(
                error: err,
                onRetry: _submit,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ).animate().slide(begin: const Offset(0, 0.2), curve: Curves.easeOut);
  }
}
