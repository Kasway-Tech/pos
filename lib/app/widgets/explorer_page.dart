import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/macos_title_bar.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key, required this.url});
  final String url;

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return MacOSTitleBar(
      child: Scaffold(
        appBar: BlurAppBar(
          title: const Text('Explorer'),
          bottom: _progress < 1.0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 2,
                  ),
                )
              : null,
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          onProgressChanged: (_, progress) =>
              setState(() => _progress = progress / 100),
        ),
      ),
    );
  }
}
