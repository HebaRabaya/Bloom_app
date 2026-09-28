import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

class SupportService {
  Future<void> openWhatsApp({String? message}) async {
    final text = Uri.encodeComponent(
      message ?? AppConfig.whatsappGreeting,
    );
    await _open(
      Uri.parse('https://wa.me/${AppConfig.whatsappNumber}?text=$text'),
      'Unable to open WhatsApp.',
    );
  }

  Future<void> openEmail() async {
    await _open(
      Uri(
        scheme: 'mailto',
        path: AppConfig.supportEmail,
        query: 'subject=Bloom support',
      ),
      'Unable to open email.',
    );
  }

  Future<void> openPhone() async {
    await _open(
      Uri(scheme: 'tel', path: '+${AppConfig.whatsappNumber}'),
      'Unable to start a call.',
    );
  }

  Future<void> _open(Uri uri, String error) async {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw Exception(error);
    }
  }
}
