import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';

enum AdminWhatsappPurpose {
  menuRequest,
  allergyPreference,
  complaint,
  debtPayment,
  other,
}

class AdminWhatsappService {
  static Uri buildUri({
    required AdminWhatsappPurpose purpose,
    String name = 'Humiiu',
    String kelas = 'XII IPS 2',
    int total = 0,
    String periode = 'Minggu ini',
    String details = '',
  }) {
    final message = _buildMessage(
      purpose: purpose,
      name: name,
      kelas: kelas,
      total: total,
      periode: periode,
      details: details,
    );

    return Uri.parse(
      'https://wa.me/${AppConstants.ADMIN_WA_NUMBER}?text=${Uri.encodeComponent(message)}',
    );
  }

  /// Membuka tautan WhatsApp Admin dengan fallback penanganan error gracefully
  static Future<bool> open({
    required AdminWhatsappPurpose purpose,
    String name = 'Humiiu',
    String kelas = 'XII IPS 2',
    int total = 0,
    String periode = 'Minggu ini',
    String details = '',
  }) async {
    final uri = buildUri(
      purpose: purpose,
      name: name,
      kelas: kelas,
      total: total,
      periode: periode,
      details: details,
    );

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static String _buildMessage({
    required AdminWhatsappPurpose purpose,
    required String name,
    required String kelas,
    required int total,
    required String periode,
    required String details,
  }) {
    final amountText = 'Rp ${total.toString().replaceAllMapped(
      RegExp(r'(?<=\d)(?=(\d{3})+$)'),
      (_) => '.',
    )}';

    switch (purpose) {
      case AdminWhatsappPurpose.menuRequest:
        return 'Halo Admin Dian Catering, saya $name ($kelas). Saya ingin request menu: ${details.isEmpty ? '...' : details}';
      case AdminWhatsappPurpose.allergyPreference:
        return 'Halo Admin Dian Catering, saya $name ($kelas). Saya punya alergi/preferensi makanan: ${details.isEmpty ? '...' : details}';
      case AdminWhatsappPurpose.complaint:
        return 'Halo Admin Dian Catering, saya $name ($kelas). Saya ingin menyampaikan keluhan tentang pesanan: ${details.isEmpty ? '...' : details}';
      case AdminWhatsappPurpose.debtPayment:
        return 'Halo Admin Dian Catering, saya $name ($kelas). Saya ingin konfirmasi pembayaran / pengajuan hutang untuk pesanan $periode. Total: $amountText.';
      case AdminWhatsappPurpose.other:
        return 'Halo Admin Dian Catering, saya $name ($kelas). Saya butuh bantuan terkait: ${details.isEmpty ? '...' : details}';
    }
  }
}
