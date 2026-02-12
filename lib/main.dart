import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(home: ShofyouApp(), debugShowCheckedModeBanner: false));

class ShofyouApp extends StatefulWidget {
  const ShofyouApp({super.key});
  @override
  State<ShofyouApp> createState() => _ShofyouAppState();
}

class _ShofyouAppState extends State<ShofyouApp> {
  late final WebViewController _controller;
  bool _isReels = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() => _isReels = url.contains('/reels') || url.contains('/watch'));
        },
        onNavigationRequest: (request) {
          if (!request.url.contains("shofyou.com")) {
            launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse('https://shofyou.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (await _controller.canGoBack()) {
            _controller.goBack();
            return false;
          }
          return true;
        },
        child: SafeArea(
          child: RefreshIndicator(
            notificationPredicate: (notification) => !_isReels,
            onRefresh: () => _controller.reload(),
            child: WebViewWidget(controller: _controller),
          ),
        ),
      ),
    );
  }
}

