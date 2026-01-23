import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flow_state/core/theme.dart';
import 'package:flow_state/data/services/services_provider.dart';
import 'package:flow_state/data/services/article_service.dart';
import 'package:flow_state/ui/widgets/neo_loading.dart';
import 'package:flow_state/ui/widgets/neo_error.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String url;

  const ReaderScreen({super.key, required this.url});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late Future<ArticleContent> _articleFuture;

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  void _fetchArticle() {
    _articleFuture = ref.read(articleServiceProvider).fetchArticle(widget.url);
  }

  Future<void> _launchOriginalUrl() async {
    final uri = Uri.parse(widget.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open original URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.black),
            tooltip: 'View Original',
            onPressed: _launchOriginalUrl,
          ),
        ],
      ),
      body: FutureBuilder<ArticleContent>(
        future: _articleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: NeoLoading(message: 'Extracting content...'));
          } else if (snapshot.hasError) {
            return Center(
                child: NeoError(
                    error: snapshot.error!,
                    onRetry: () {
                      setState(() {
                        _fetchArticle();
                      });
                    }));
          } else if (snapshot.hasData) {
            final article = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts.merriweather(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Html(
                    data: article.contentHtml,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontFamily: GoogleFonts.merriweather().fontFamily,
                        fontSize: FontSize(18),
                        lineHeight: const LineHeight(1.6),
                        color: Colors.black87,
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 16),
                      ),
                      "h1": Style(
                          fontSize: FontSize(22), fontWeight: FontWeight.bold),
                      "h2": Style(
                          fontSize: FontSize(20), fontWeight: FontWeight.bold),
                      "a": Style(
                        textDecoration: TextDecoration.none,
                        color: AppTheme.accent,
                      ),
                      "img": Style(
                        display: Display.block,
                        width: Width(100, Unit.percent),
                        margin: Margins.symmetric(vertical: 20),
                      ),
                    },
                    onLinkTap: (url, _, __) {
                      if (url != null) {
                        launchUrl(Uri.parse(url));
                      }
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
