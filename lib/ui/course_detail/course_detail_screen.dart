import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:intl/intl.dart';
import '../../data/models/course.dart';
import '../../data/models/video.dart';
import '../../data/repositories/course_repository.dart';
import '../../core/theme.dart';
import '../widgets/glass_card.dart';
import '../player/video_player_screen.dart';
import '../reader/reader_screen.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  late TextEditingController _titleController;
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _isArticleCourse {
    return widget.course.videos.any(
      (v) => v.resourceType == 'url' || v.resourceType == 'article',
    );
  }

  void _toggleTitleEdit() {
    setState(() {
      if (_isEditingTitle) {
        // Save the new title
        final newTitle = _titleController.text.trim();
        if (newTitle.isNotEmpty && newTitle != widget.course.title) {
          // Update the course title in the database
          final courseRepo = ref.read(courseRepositoryProvider);
          final updatedCourse = widget.course.copyWith(title: newTitle);
          courseRepo.updateCourse(updatedCourse);
        } else {
          // Reset to original if empty
          _titleController.text = widget.course.title;
        }
      }
      _isEditingTitle = !_isEditingTitle;
    });
  }

  void _deleteCourse() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Course?'),
          content: Text(
              'Are you sure you want to delete "${widget.course.title}"? This will delete all resources in this course. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                Navigator.pop(dialogContext); // Close dialog
                final courseRepo = ref.read(courseRepositoryProvider);
                await courseRepo.deleteCourse(widget.course.id);

                navigator.pop(); // Go back to dashboard
                messenger.showSnackBar(
                  SnackBar(content: Text('${widget.course.title} deleted')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    final completedVideos =
        widget.course.videos.where((v) => v.isCompleted).length;
    final progress = widget.course.totalDuration > 0
        ? (widget.course.watchedDuration / widget.course.totalDuration)
        : 0.0;
    final remainingSeconds =
        widget.course.totalDuration - widget.course.watchedDuration;
    final remainingDuration = Duration(seconds: remainingSeconds);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppTheme.background,
            actions: [
              IconButton(
                icon: Icon(_isEditingTitle ? Icons.check : Icons.edit),
                onPressed: _toggleTitleEdit,
                tooltip: _isEditingTitle ? 'Save' : 'Edit Title',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteCourse,
                tooltip: 'Delete Course',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: _isEditingTitle
                  ? SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                        onSubmitted: (_) => _toggleTitleEdit(),
                      ),
                    )
                  : Text(
                      widget.course.title,
                      style: TextStyle(
                        fontSize: _isArticleCourse ? 20 : 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              titlePadding: EdgeInsets.only(
                left: _isArticleCourse ? 48 : 56,
                bottom: 16,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.course.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Complete',
                      value: '${(progress * 100).toInt()}%',
                    ),
                    _StatItem(
                      label: 'Left',
                      value: _formatDuration(remainingDuration),
                    ),
                    _StatItem(
                      label: 'Streak',
                      value: '$completedVideos', // Placeholder logic for streak
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final video = widget.course.videos[index];
                final isCurrent = video.id == widget.course.lastPlayedVideoId;

                return Dismissible(
                  key: Key(video.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Delete Resource?'),
                          content: Text(
                              'Are you sure you want to delete "${video.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    final courseRepo = ref.read(courseRepositoryProvider);
                    await courseRepo.deleteResourceFromCourse(
                        widget.course.id, video.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${video.title} deleted')),
                      );
                    }
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  child: _VideoListItem(
                    video: video,
                    isCurrent: isCurrent,
                    index: index,
                    onTap: () {
                      if (video.resourceType == 'url' ||
                          video.resourceType == 'article') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReaderScreen(
                              url: video.content ?? '',
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              course: widget.course,
                              initialVideoId: video.id,
                            ),
                          ),
                        );
                      }
                    },
                  )
                      .animate(delay: Duration(milliseconds: 30 * index))
                      .fadeIn()
                      .slideX(),
                );
              },
              childCount: widget.course.videos.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.accent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _VideoListItem extends StatelessWidget {
  final Video video;
  final bool isCurrent;
  final int index;
  final VoidCallback onTap;

  const _VideoListItem({
    required this.video,
    required this.isCurrent,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: isCurrent ? AppTheme.accent.withValues(alpha: 0.05) : null,
      leading: Container(
        width: 40,
        alignment: Alignment.center,
        child: video.isCompleted
            ? const Icon(Icons.check_circle, color: AppTheme.accent)
            : Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      title: Text(
        video.title,
        style: TextStyle(
          color: video.isCompleted ? AppTheme.textSecondary : Colors.white,
          decoration: video.isCompleted ? TextDecoration.lineThrough : null,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${(video.durationSeconds / 60).toStringAsFixed(0)} mins',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: isCurrent
          ? const Icon(Icons.play_arrow, color: AppTheme.accent)
          : null,
    );
  }
}
