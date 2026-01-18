import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:uuid/uuid.dart';
import '../models/video.dart';
import '../models/course.dart';

class YouTubeService {
  final yt.YoutubeExplode _yt = yt.YoutubeExplode();
  final Uuid _uuid = const Uuid();

  Future<Course> extractCourse(String url) async {
    try {
      if (url.contains('playlist?list=')) {
        return _extractPlaylist(url);
      } else {
        return _extractSingleVideo(url);
      }
    } catch (e) {
      throw Exception('Failed to extract course: $e');
    }
  }

  Future<Course> _extractPlaylist(String url) async {
    final playlistId = yt.PlaylistId.parsePlaylistId(url);
    final playlist = await _yt.playlists.get(playlistId);
    
    final videos = <Video>[];
    var totalDuration = 0;

    await for (final video in _yt.playlists.getVideos(playlistId)) {
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

  Future<Course> _extractSingleVideo(String url) async {
    final videoId = yt.VideoId.parseVideoId(url);
    final video = await _yt.videos.get(videoId);

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
  
  void dispose() {
    _yt.close();
  }
}
