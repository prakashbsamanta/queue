import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flow_state/data/services/article_service.dart';

@GenerateMocks([http.Client])
import 'article_service_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late ArticleService articleService;

  setUp(() {
    mockClient = MockClient();
    articleService = ArticleService(mockClient);
  });

  const sampleHtml = '''
    <html>
      <head>
        <title>Test Article Title</title>
        <meta property="og:title" content="Better Title from OG">
      </head>
      <body>
        <nav>Menu Items</nav>
        <div class="content">
          <p>This is the main content of the article.</p>
          <p>It has multiple paragraphs to score higher in heuristics.</p>
          <p>More text to ensure this block is selected as the best candidate.</p>
        </div>
        <footer>Copyright info</footer>
      </body>
    </html>
  ''';

  test('fetchArticle extracts title and content correctly', () async {
    when(mockClient.get(Uri.parse('https://example.com/article')))
        .thenAnswer((_) async => http.Response(sampleHtml, 200));

    final article =
        await articleService.fetchArticle('https://example.com/article');

    expect(article.title, 'Better Title from OG');
    expect(article.contentHtml, contains('This is the main content'));
    expect(article.contentHtml, contains('More text'));
    expect(article.contentHtml, isNot(contains('Menu Items'))); // Nav removed
  });

  test('fetchArticle throws exception on non-200 response', () async {
    when(mockClient.get(Uri.parse('https://example.com/notfound')))
        .thenAnswer((_) async => http.Response('Not Found', 404));

    expect(
      () => articleService.fetchArticle('https://example.com/notfound'),
      throwsException,
    );
  });

  test('fetchArticle extracts thumbnail URL from og:image', () async {
    const htmlWithThumbnail = '''
      \u003chtml\u003e
        \u003chead\u003e
          \u003ctitle\u003eArticle with Image\u003c/title\u003e
          \u003cmeta property="og:image" content="https://example.com/thumb.jpg"\u003e
        \u003c/head\u003e
        \u003cbody\u003e
          \u003carticle\u003e
            \u003cp\u003eArticle content here.\u003c/p\u003e
          \u003c/article\u003e
        \u003c/body\u003e
      \u003c/html\u003e
    ''';

    when(mockClient.get(Uri.parse('https://example.com/article-with-image')))
        .thenAnswer((_) async => http.Response(htmlWithThumbnail, 200));

    final article = await articleService
        .fetchArticle('https://example.com/article-with-image');

    expect(article.thumbnailUrl, 'https://example.com/thumb.jpg');
  });
}
