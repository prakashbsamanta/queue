import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart'; // For MethodChannel
import 'package:flow_state/ui/reader/reader_screen.dart';
import 'package:flow_state/data/services/services_provider.dart';
import 'package:flow_state/data/services/article_service.dart';

// Mock ArticleService
class MockArticleService extends Mock implements ArticleService {
  @override
  Future<ArticleContent> fetchArticle(String url) {
    return super.noSuchMethod(
      Invocation.method(#fetchArticle, [url]),
      returnValue:
          Future.value(ArticleContent(title: '', contentHtml: '', url: '')),
    );
  }
}

void main() {
  late MockArticleService mockService;

  setUp(() {
    mockService = MockArticleService();

    // Mock url_launcher
    const MethodChannel('plugins.flutter.io/url_launcher')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'canLaunch') {
        return true;
      }
      return null;
    });
  });

  testWidgets('ReaderScreen shows loading then content',
      (WidgetTester tester) async {
    const testUrl = 'https://example.com/test';
    final testContent = ArticleContent(
      title: 'Test Article',
      contentHtml: '<p>Hello World</p>',
      url: testUrl,
    );

    when(mockService.fetchArticle(testUrl)).thenAnswer((_) async {
      await Future.delayed(
          const Duration(milliseconds: 100)); // Simulate net delay
      return testContent;
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          articleServiceProvider.overrideWith((ref) => mockService),
        ],
        child: const MaterialApp(home: ReaderScreen(url: testUrl)),
      ),
    );

    // Should show loading
    expect(find.text('Extracting content...'), findsOneWidget);

    await tester.pumpAndSettle();

    // Should show content
    expect(find.text('Test Article'), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('ReaderScreen shows error on failure',
      (WidgetTester tester) async {
    const testUrl = 'https://example.com/fail';

    when(mockService.fetchArticle(testUrl))
        .thenAnswer((_) async => throw Exception('Net Error'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          articleServiceProvider.overrideWith((ref) => mockService),
        ],
        child: const MaterialApp(home: ReaderScreen(url: testUrl)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Net Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
