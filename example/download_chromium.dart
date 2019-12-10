import 'package:puppeteer/puppeteer.dart';

Future<void> main() async {
  var chromePath = await downloadChrome(
      // Specify the custom location (by default it .local-chromium)
      cachePath: null);
  print(chromePath.executablePath);
}
