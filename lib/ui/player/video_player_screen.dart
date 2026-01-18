import 'dart:async';
// import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/models/course.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../core/theme.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final Course course;
  final String initialVideoId;

  const VideoPlayerScreen({
    super.key,
    required this.course,
    required this.initialVideoId,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late String _currentVideoId;
  final bool _isPlayerReady = false;
  Timer? _syncTimer;
  DateTime? _lastSyncTime;

  bool get _isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _currentVideoId = widget.initialVideoId;
    if (_isSupported) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    final video = widget.course.videos.firstWhere((v) => v.id == _currentVideoId);
    
    _controller = YoutubePlayerController(
      initialVideoId: video.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );

    _lastSyncTime = DateTime.now();
    _startSyncTimer();
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isSupported && _controller.value.isPlaying) {
        _syncProgress();
      }
    });
  }

  Future<void> _syncProgress() async {
    final positionService = ref.read(courseRepositoryProvider);
    final analyticsService = ref.read(analyticsRepositoryProvider);
    
    final position = _controller.value.position.inSeconds;
    
    // Update Video Progress
    await positionService.updateVideoProgress(
      widget.course.id,
      _currentVideoId,
      position,
    );

    // Update Analytics (Time spent since last sync)
    final now = DateTime.now();
    if (_lastSyncTime != null) {
      final diff = now.difference(_lastSyncTime!).inSeconds;
      if (diff > 0) {
        await analyticsService.logSession(diff);
      }
    }
    _lastSyncTime = now;
  }

  @override
  void deactivate() {
    if (_isSupported) {
       // Sync one last time
       _syncProgress();
       _controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    if (_isSupported) {
       _controller.dispose();
       SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupported) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.desktop_mac, size: 80, color: AppTheme.textSecondary),
              const SizedBox(height: 20),
              Text(
                'Video Playback Not Supported on Desktop/Web',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
               const SizedBox(height: 10),
               const Text(
                'Please use the mobile app for the immersive player experience.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.accent,
        onReady: () {
          // Seek to last watched position?
          // We could grab it from widget.course.videos...watchedSeconds
          final video = widget.course.videos.firstWhere((v) => v.id == _currentVideoId);
          if (video.watchedSeconds > 0 && video.watchedSeconds < video.durationSeconds) {
            _controller.seekTo(Duration(seconds: video.watchedSeconds));
          }
        },
        bottomActions: [
           CurrentPosition(),
           ProgressBar(isExpanded: true, colors: const ProgressBarColors(
             playedColor: AppTheme.accent,
             handleColor: AppTheme.accent,
           )),
           RemainingDuration(),
           const PlaybackSpeedButton(),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(child: player),
        );
      },
    );
  }
}
