import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'youtube_service.dart';
import 'article_service.dart';

part 'services_provider.g.dart';

@riverpod
YouTubeService youTubeService(YouTubeServiceRef ref) {
  return YouTubeService();
}

@riverpod
ArticleService articleService(ArticleServiceRef ref) {
  return ArticleService();
}
