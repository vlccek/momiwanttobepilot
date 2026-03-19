import 'dart:convert';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

Future<void> downloadJsonWeb(String jsonString, String fileName) async {
  final bytes = utf8.encode(jsonString);
  final base64 = base64Encode(bytes);
  final url = 'data:application/json;base64,$base64';
  
  final document = js.globalContext.getProperty('document'.toJS) as js.JSObject;
  final anchor = document.callMethod('createElement'.toJS, 'a'.toJS) as js.JSObject;
      
  anchor.setProperty('href'.toJS, url.toJS);
  anchor.setProperty('download'.toJS, fileName.toJS);
  anchor.callMethod('click'.toJS);
}
