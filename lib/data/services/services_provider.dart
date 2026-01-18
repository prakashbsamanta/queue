import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'youtube_service.dart';

part 'services_provider.g.dart';

@riverpod
YouTubeService youTubeService(YouTubeServiceRef ref) {
  return YouTubeService();
}
