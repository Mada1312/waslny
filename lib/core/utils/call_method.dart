import 'package:url_launcher/url_launcher.dart';

void phoneCallMethod(String phone) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: '+$phone',
  );
  await launchUrl(launchUri);
  // await launchUrl(Uri.parse('tel:$phone'));
}

Future<void> openExternal(String urlString) async {
  final url = Uri.parse(urlString);

  // Optional guard—skip it if you’re sure every URL scheme is supported.
  if (!await canLaunchUrl(url)) {
    throw Exception('No external handler for $urlString');
  }

  final ok = await launchUrl(
    url,
    mode: LaunchMode.externalApplication, // Always external
  );

  if (!ok) throw Exception('Couldn’t launch $urlString');
}
