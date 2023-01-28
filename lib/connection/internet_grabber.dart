import 'package:http/http.dart';

class InternetGrabber {
  static Future<String> request(
      {required Uri url,
      Map<String, String>? headers,
      String method = 'GET'}) async {
    final request = Request(method, url);

    request.headers.addAll({
      ...(headers ?? {}),
      'Content-Type': 'application/x-www-form-urlencoded'
    });

    request.followRedirects = false;
    try {
      final res = await request.send();

      String response = await res.stream.bytesToString();
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }
}
