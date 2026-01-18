import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:intl/intl.dart';
import '../../data/models/course.dart';
import '../../data/models/video.dart';
import '../../core/theme.dart';
import '../widgets/glass_card.dart';
import '../player/video_player_screen.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate stats
    final completedVideos = course.videos.where((v) => v.isCompleted).length;
    final progress = course.totalDuration > 0 
        ? (course.watchedDuration / course.totalDuration)
        : 0.0;
    final remainingSeconds = course.totalDuration - course.watchedDuration;
    final remainingDuration = Duration(seconds: remainingSeconds);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                course.title,
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                   CachedNetworkImage(
                    imageUrl: course.thumbnailUrl,
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
                final video = course.videos[index];
                final isCurrent = video.id == course.lastPlayedVideoId;
                
                return _VideoListItem(
                  video: video,
                  isCurrent: isCurrent,
                  index: index,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          course: course,
                          initialVideoId: video.id,
                        ),
                      ),
                    );
                  },
                ).animate(delay: Duration(milliseconds: 30 * index)).fadeIn().slideX();
              },
              childCount: course.videos.length,
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
      tileColor: isCurrent ? AppTheme.accent.withOpacity(0.05) : null,
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
