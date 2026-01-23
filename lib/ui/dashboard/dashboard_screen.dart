import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../logic/auth/auth_provider.dart';

import '../../core/theme.dart';
import '../../logic/providers.dart';
import '../../data/models/course.dart';
import '../widgets/glass_card.dart';
import '../add_course/add_course_modal.dart';
import '../course_detail/course_detail_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets/neo_loading.dart';
import '../widgets/neo_error.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Duration openModalDelay;

  const DashboardScreen({
    super.key,
    this.openModalDelay = const Duration(milliseconds: 500),
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  StreamSubscription? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    try {
      // For sharing or opening urls/text coming from outside the app while the app is in the memory
      _intentDataStreamSubscription = ReceiveSharingIntent.instance
          .getMediaStream()
          .listen((List<SharedMediaFile> value) {
        _handleSharedContent(value);
      }, onError: (err) {
        debugPrint("getIntentDataStream error: $err");
      });

      // For sharing or opening urls/text coming from outside the app while the app is closed
      ReceiveSharingIntent.instance
          .getInitialMedia()
          .then((List<SharedMediaFile> value) {
        _handleSharedContent(value);
        // Optional: Tell the library that we are done processing the intent
        ReceiveSharingIntent.instance.reset();
      }).catchError((err) {
        debugPrint("getInitialMedia error: $err");
      });
    } catch (e) {
      debugPrint("Share Intent Init Error: $e");
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  void _handleSharedContent(List<SharedMediaFile> sharedFiles) {
    if (sharedFiles.isNotEmpty) {
      // Assuming text sharing puts the text in the path or we can inspect content
      // receive_sharing_intent usually normalizes text to be allowed here.
      // We take the first item.
      final text = sharedFiles.first.path;
      if (text.isNotEmpty) {
        _openAddModal(text);
      }
    }
  }

  void _openAddModal(String text) {
    if (!mounted) return;

    // Add a small delay to ensure UI is ready if coming from cold start
    Future.delayed(widget.openModalDelay, () {
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => AddCourseModal(initialUrl: text),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(allCoursesProvider);
    final currentFocus = ref.watch(currentFocusProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddModal('');
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
                      children: const [
                        _GreetingHeader(),
                      ],
                    ),
                  ),

                  // Chart Button (Right)
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()));
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AnalyticsScreen()));
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
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: NeoError(error: err),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: NeoLoading(message: 'Loading Library...'),
              ),
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
          MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course)),
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
          MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course)),
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
                  placeholder: (context, url) =>
                      Container(color: AppTheme.surface),
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

class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);
    final user = userAsync.value;
    final name = user?.displayName?.split(' ').first ?? 'User';

    String greeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return 'Good Morning,';
      if (hour < 17) return 'Good Afternoon,';
      return 'Good Evening,';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          name,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}
