import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../logic/add_course_logic.dart';
import '../../core/theme.dart';
import '../widgets/neo_button.dart';

class AddCourseModal extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const AddCourseModal({super.key});

  @override
  ConsumerState<AddCourseModal> createState() => _AddCourseModalState();
}

class _AddCourseModalState extends ConsumerState<AddCourseModal> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override // Dispose controller
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(addCourseLogicProvider.notifier).addCourseFromUrl(_urlController.text);
      if (mounted && !ref.read(addCourseLogicProvider).hasError) {
           Navigator.pop(context);
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Course Added Successfully')),
           );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state to show errors or loading
    final addCourseState = ref.watch(addCourseLogicProvider);

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
            const SizedBox(height: 20),
            TextFormField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Paste YouTube Playlist or Video URL',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.link, color: AppTheme.accent),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
                  return 'Invalid YouTube URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            addCourseState.when(
              data: (_) => SizedBox(
                width: double.infinity,
                child: NeoButton(
                  text: 'Extract & Add',
                  onPressed: _submit,
                  icon: Icons.download_rounded,
                ),
              ),
              loading: () => const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.accent),
                    SizedBox(height: 10),
                    Text('Extracting Knowledge...'),
                  ],
                ),
              ),
              error: (err, stack) => Column(
                children: [
                  Text(
                    'Error: $err',
                    style: const TextStyle(color: AppTheme.error),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: NeoButton(
                      text: 'Retry',
                      onPressed: _submit,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ).animate().slide(begin: const Offset(0, 0.2), curve: Curves.easeOut);
  }
}
