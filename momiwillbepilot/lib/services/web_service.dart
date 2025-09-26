
import 'package:universal_html/html.dart' as html;

class WebService {
  static void download(List<int> bytes, String downloadName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", downloadName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
