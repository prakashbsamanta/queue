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

  test('fetchArticle extracts thumbnail from twitter:image fallback', () async {
    const htmlWithTwitterImage = '''
      <html>
        <head>
          <title>Article with Twitter Image</title>
          <meta name="twitter:image" content="https://example.com/twitter-thumb.jpg">
        </head>
        <body>
          <article>
            <p>Article content here.</p>
          </article>
        </body>
      </html>
    ''';

    when(mockClient.get(Uri.parse('https://example.com/twitter-article')))
        .thenAnswer((_) async => http.Response(htmlWithTwitterImage, 200));

    final article = await articleService
        .fetchArticle('https://example.com/twitter-article');

    expect(article.thumbnailUrl, 'https://example.com/twitter-thumb.jpg');
  });

  test('fetchArticle makes relative thumbnail URLs absolute', () async {
    const htmlWithRelativeImage = '''
      <html>
        <head>
          <title>Article with Relative Image</title>
        </head>
        <body>
          <article>
            <img src="/images/thumb.jpg">
            <p>Article content here with enough text to score high.</p>
          </article>
        </body>
      </html>
    ''';

    when(mockClient.get(Uri.parse('https://example.com/relative-article')))
        .thenAnswer((_) async => http.Response(htmlWithRelativeImage, 200));

    final article = await articleService
        .fetchArticle('https://example.com/relative-article');

    expect(article.thumbnailUrl, 'https://example.com/images/thumb.jpg');
  });

  test('fetchArticle handles relative URL without leading slash', () async {
    const htmlWithRelativeNoSlash = '''
      <html>
        <head>
          <title>Article</title>
        </head>
        <body>
          <article>
            <img src="images/thumb.jpg">
            <p>Content here to make this the main article section.</p>
          </article>
        </body>
      </html>
    ''';

    when(mockClient.get(Uri.parse('https://example.com/no-slash-article')))
        .thenAnswer((_) async => http.Response(htmlWithRelativeNoSlash, 200));

    final article = await articleService
        .fetchArticle('https://example.com/no-slash-article');

    expect(article.thumbnailUrl, 'https://example.com/images/thumb.jpg');
  });

  test('fetchArticle falls back to title tag when no og:title', () async {
    const htmlNoOg = '''
      <html>
        <head>
          <title>Simple Title</title>
        </head>
        <body>
          <p>Main content paragraph with enough text to be selected.</p>
        </body>
      </html>
    ''';

    when(mockClient.get(Uri.parse('https://example.com/simple')))
        .thenAnswer((_) async => http.Response(htmlNoOg, 200));

    final article =
        await articleService.fetchArticle('https://example.com/simple');

    expect(article.title, 'Simple Title');
  });
}
