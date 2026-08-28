import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WhatmoreReelsView extends StatefulWidget {
  const WhatmoreReelsView({super.key});

  @override
  State<WhatmoreReelsView> createState() => _WhatmoreReelsViewState();
}

class _WhatmoreReelsViewState extends State<WhatmoreReelsView> with AutomaticKeepAliveClientMixin {
  late final WebViewController controller;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; // Isse scroll karne par Reels reload nahi hongi

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    if (kDebugMode && WebViewPlatform.instance is AndroidWebViewPlatform) {
      AndroidWebViewController.enableDebugging(true);
    }

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(_htmlContent, baseUrl: 'https://kdtdiamond.com');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Stack(
      children: [
        WebViewWidget(
          controller: controller,
          // Sirf HorizontalDrag allow kiya hai taaki user Home screen ko vertically scroll kar sake
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer()),
          },
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}

const String _htmlContent = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: 100%; height: 100%; background: transparent; overflow: hidden; }
  .whatmore-render-root { width: 100%; height: 100%; overflow-x: auto; -webkit-overflow-scrolling: touch; }
</style>
</head>
<body>
  <script src="https://d1qflh9ill7vje.cloudfront.net/whatmore.js" defer></script>
  <div id="whatmoreShopId" data-wh="STR1NATABM6"></div>
  <div class="whatmore-template-type" data-wh="template-h"></div>
  <div class="whatmore-widget" data-wh="carousel"></div>
  <div class="whatmore-render-root"></div>
</body>
</html>
''';
