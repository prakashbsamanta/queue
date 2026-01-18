import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../logic/providers.dart';
import '../../data/models/course.dart';
import '../widgets/glass_card.dart';
import '../add_course/add_course_modal.dart';
import '../course_detail/course_detail_screen.dart';
import '../analytics/analytics_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(allCoursesProvider);
    final currentFocus = ref.watch(currentFocusProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddCourseModal(),
          );
        },
        backgroundColor: AppTheme.accent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  // Text (Expanded to prevent overflow)
                  
                  // Text (Expanded to prevent overflow)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning,',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        Text(
                          'Ready to Flow?',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith( // Reduced from displayLarge
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ), 
                        ),
                      ],
                    ),
                  ),
                  
                  // Chart Button (Right)
                  IconButton(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsScreen()));
                    },
                    icon: const Icon(Icons.bar_chart, color: AppTheme.accent),
                  ),
                ],
              ).animate().fadeIn().moveY(begin: 10, end: 0),
            ),
          ),
          if (currentFocus != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverToBoxAdapter(
                child: _CurrentFocusCard(course: currentFocus),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Text(
                'My Library',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          coursesAsync.when(
            data: (courses) {
              if (courses.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        'No courses yet. Add one to start.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75, // Taller cards
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = courses[index];
                      return _CourseCard(course: course)
                          .animate(delay: Duration(milliseconds: 50 * index))
                          .scale()
                          .fadeIn();
                    },
                    childCount: courses.length,
                  ),
                ),
              );
            },
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $err')),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}

class _CurrentFocusCard extends StatelessWidget {
  final Course course;

  const _CurrentFocusCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opacity: 0.1,
      onTap: () {
         Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CourseDetailScreen(course: course)),
          );
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: course.thumbnailUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESUME LEARNING',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final progress = course.totalDuration > 0
        ? (course.watchedDuration / course.totalDuration).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CourseDetailScreen(course: course)),
          );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image (Dimmed)
            Positioned.fill(
              child: Opacity(
                opacity: 0.6,
                child: CachedNetworkImage(
                  imageUrl: course.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppTheme.surface),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
             // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Liquid Progress Effect (Simplified as a colored overlay at bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180 * progress, // Fills up based on progress
              child: Container(
                color: AppTheme.accent.withValues(alpha: 0.2),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    color: AppTheme.accent,
                    minHeight: 4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
