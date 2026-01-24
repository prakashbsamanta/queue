import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class ArticleContent {
  final String title;
  final String contentHtml;
  final String url;
  final String? thumbnailUrl;

  ArticleContent({
    required this.title,
    required this.contentHtml,
    required this.url,
    this.thumbnailUrl,
  });
}

class ArticleService {
  final http.Client _client;

  ArticleService([http.Client? client]) : _client = client ?? http.Client();

  Future<ArticleContent> fetchArticle(String url) async {
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load article');
    }

    final document = parser.parse(response.body);

    // Heuristic 1: Title
    // Try meta og:title, then title tag
    String? title = document
        .querySelector('meta[property="og:title"]')
        ?.attributes['content'];
    title ??= document.querySelector('title')?.text;
    title ??= 'No Title';

    // Heuristic 1.5: Thumbnail
    // Try og:image, then twitter:image, then first img tag
    String? thumbnailUrl = document
        .querySelector('meta[property="og:image"]')
        ?.attributes['content'];
    thumbnailUrl ??= document
        .querySelector('meta[name="twitter:image"]')
        ?.attributes['content'];
    thumbnailUrl ??= document
        .querySelector('meta[property="og:image:url"]')
        ?.attributes['content'];

    // If no meta image, try to find first image in content
    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      final firstImg =
          document.querySelector('article img, main img, .content img, img');
      thumbnailUrl = firstImg?.attributes['src'];

      // Make relative URLs absolute
      if (thumbnailUrl != null && !thumbnailUrl.startsWith('http')) {
        final uri = Uri.parse(url);
        if (thumbnailUrl.startsWith('/')) {
          thumbnailUrl = '${uri.scheme}://${uri.host}$thumbnailUrl';
        } else {
          thumbnailUrl = '${uri.scheme}://${uri.host}/$thumbnailUrl';
        }
      }
    }

    // Heuristic 2: Content (Simplified)
    // Find the element with the most text content that isn't script, style, or nav
    _removeUnwantedTags(document);

    Element? bestCandidate;
    int maxScore = 0;

    // We look at typical article containers
    final candidates = document.querySelectorAll(
        'article, main, div.content, div.post, div.article, div.entry-content, body');

    // If specific containers found, verify them, otherwise fallback to body
    final searchScope = candidates.isNotEmpty ? candidates : [document.body!];

    for (var element in searchScope) {
      // Simple score: text length
      // A smarter algo (Readability.js) uses commas, p tags, etc.
      // Here we just count P tags length
      final pTags = element.querySelectorAll('p');
      int score = 0;
      for (var p in pTags) {
        score += p.text.length;
      }

      if (score > maxScore) {
        maxScore = score;
        bestCandidate = element;
      }
    }

    // If no p tags found, fallback to body text length
    if (bestCandidate == null || maxScore < 200) {
      bestCandidate = document.body;
    }

    // Convert Element back to HTML string, preserving structure
    // We might want to just keep the P tags? Or the whole container?
    // Let's keep the container to support h1, h2, etc. embedded in it.
    final contentHtml =
        bestCandidate?.innerHtml ?? '<p>Could not extract content.</p>';

    return ArticleContent(
      title: title,
      contentHtml: contentHtml,
      url: url,
      thumbnailUrl: thumbnailUrl,
    );
  }

  void _removeUnwantedTags(Document document) {
    // Remove scripts, styles, navs, footers, etc.
    final unwanted = document.querySelectorAll(
        'script, style, nav, footer, header, aside, .ad, .advertisement, .hidden, noscript');
    for (var element in unwanted) {
      element.remove();
    }
  }
}
