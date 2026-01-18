import 'package:flutter/foundation.dart'; // for debugPrint
import 'dart:io'; // for SocketException
import 'dart:async'; // for TimeoutException
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:uuid/uuid.dart';
import '../models/video.dart';
import '../models/course.dart';

class YouTubeService {
  final Uuid _uuid = const Uuid();

  Future<Course> extractCourse(String url) async {
    final client = yt.YoutubeExplode();
    try {
      debugPrint('🔍 Extracting YouTube URL: $url');
      final stopwatch = Stopwatch()..start();
      
      Course course;
      if (url.contains('playlist?list=')) {
        debugPrint('📂 Detected Playlist');
        course = await _extractPlaylist(client, url);
      } else {
        debugPrint('📹 Detected Single Video');
        course = await _extractSingleVideo(client, url);
      }
      
      stopwatch.stop();
      debugPrint('✅ Extraction completed in ${stopwatch.elapsedMilliseconds}ms');
      return course;
    } on SocketException catch (e) {
      debugPrint('❌ Network Error: $e');
      throw Exception('No Internet Connection. Please check your network.');
    } on TimeoutException {
      debugPrint('❌ Timeout Error');
      throw Exception('Connection timed out. YouTube is too slow to respond.');
    } catch (e) {
      debugPrint('❌ Generic Error: $e');
      throw Exception('Failed to extract course: $e');
    } finally {
      client.close();
    }
  }

  Future<Course> _extractPlaylist(yt.YoutubeExplode client, String url) async {
    final playlistId = yt.PlaylistId.parsePlaylistId(url);
    final playlist = await client.playlists.get(playlistId).timeout(const Duration(seconds: 15));
    
    final videos = <Video>[];
    var totalDuration = 0;

    await for (final video in client.playlists.getVideos(playlistId)) {
      final v = Video(
        id: _uuid.v4(),
        youtubeId: video.id.value,
        title: video.title,
        thumbnailUrl: video.thumbnails.highResUrl,
        durationSeconds: video.duration?.inSeconds ?? 0,
      );
      videos.add(v);
      totalDuration += v.durationSeconds;
    }

    return Course(
      id: _uuid.v4(),
      title: playlist.title,
      thumbnailUrl: videos.isNotEmpty ? videos.first.thumbnailUrl : '',
      sourceUrl: url,
      totalDuration: totalDuration,
      videos: videos,
      dateAdded: DateTime.now(),
    );
  }

  Future<Course> _extractSingleVideo(yt.YoutubeExplode client, String url) async {
    final videoId = yt.VideoId.parseVideoId(url);
    debugPrint('⏱️ Parsed ID: $videoId. Requesting metadata...');
    final metaStopwatch = Stopwatch()..start();
    
    final video = await client.videos.get(videoId).timeout(const Duration(seconds: 15));
    
    metaStopwatch.stop();
    debugPrint('⏱️ Metadata fetched in ${metaStopwatch.elapsedMilliseconds}ms');

    final v = Video(
      id: _uuid.v4(),
      youtubeId: video.id.value,
      title: video.title,
      thumbnailUrl: video.thumbnails.highResUrl,
      durationSeconds: video.duration?.inSeconds ?? 0,
    );

    return Course(
      id: _uuid.v4(),
      title: video.title,
      thumbnailUrl: v.thumbnailUrl,
      sourceUrl: url,
      totalDuration: v.durationSeconds,
      videos: [v],
      dateAdded: DateTime.now(),
    );
  }
}
