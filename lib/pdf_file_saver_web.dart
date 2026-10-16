import 'dart:async';
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> savePdfBytes({
  required Uint8List bytes,
  required String filename,
  required String subject,
}) async {
  if (bytes.isEmpty) {
    throw ArgumentError('Cannot download an empty PDF.');
  }

  final body = html.document.body;
  if (body == null) {
    throw StateError('The browser page is not ready.');
  }

  var safeName = filename.trim();
  if (safeName.isEmpty) {
    safeName = 'Zingacc-Learn-AI-Answer.pdf';
  }
  safeName = safeName.replaceAll(
    RegExp(r'[\\/:*?"<>|\x00-\x1F]'),
    '_',
  );
  if (!safeName.toLowerCase().endsWith('.pdf')) {
    safeName = '$safeName.pdf';
  }

  final blob = html.Blob(<dynamic>[bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final panel = html.DivElement()
    ..style.position = 'fixed'
    ..style.right = '16px'
    ..style.bottom = '16px'
    ..style.zIndex = '2147483647'
    ..style.padding = '12px'
    ..style.backgroundColor = '#07132F'
    ..style.border = '2px solid #16D9FF'
    ..style.borderRadius = '12px'
    ..style.boxShadow = '0 4px 18px rgba(0,0,0,0.35)';

  Timer? closeTimer;
  Timer? revokeTimer;
  bool dismissed = false;

  void dismissPanel() {
    if (dismissed) return;
    dismissed = true;
    closeTimer?.cancel();
    panel.remove();
    // Keep the blob URL alive briefly for an in-progress download/new tab.
    revokeTimer ??= Timer(const Duration(minutes: 10), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  final closeButton = html.ButtonElement()
    ..text = '×'
    ..title = 'වසන්න';
  closeButton.style
    ..display = 'block'
    ..marginLeft = 'auto'
    ..marginBottom = '6px'
    ..backgroundColor = 'transparent'
    ..border = 'none'
    ..color = '#FFFFFF'
    ..fontSize = '22px'
    ..cursor = 'pointer';
  closeButton.onClick.listen((_) => dismissPanel());

  final downloadLink = html.AnchorElement(href: url)
    ..download = safeName
    ..text = 'PDF බාගන්න: $safeName';
  downloadLink.style
    ..display = 'block'
    ..padding = '12px 16px'
    ..marginBottom = '8px'
    ..backgroundColor = '#7048E8'
    ..color = '#FFFFFF'
    ..borderRadius = '8px'
    ..textDecoration = 'none'
    ..fontSize = '16px';
  downloadLink.onClick.listen((_) => dismissPanel());

  final openLink = html.AnchorElement(href: url)
    ..target = '_blank'
    ..rel = 'noopener'
    ..text = 'PDF වෙනම පිටුවක විවෘත කරන්න';
  openLink.style
    ..display = 'block'
    ..padding = '12px 16px'
    ..backgroundColor = '#1769FF'
    ..color = '#FFFFFF'
    ..borderRadius = '8px'
    ..textDecoration = 'none'
    ..fontSize = '16px';
  openLink.onClick.listen((_) => dismissPanel());

  panel.children
    ..add(closeButton)
    ..add(downloadLink)
    ..add(openLink);
  body.children.add(panel);

  print('PDF WEB: ready for ${subject.trim().isEmpty ? 'answer' : subject}');

  closeTimer = Timer(const Duration(minutes: 2), dismissPanel);
  // Even if the panel is never dismissed, release the object URL later.
  Timer(const Duration(minutes: 12), () {
    revokeTimer?.cancel();
    html.Url.revokeObjectUrl(url);
    dismissPanel();
  });
}
