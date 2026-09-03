import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Halaman promosi untuk aplikasi Catering Booking.
/// Menampilkan deskripsi singkat, keunggulan, dan tombol untuk
/// mengunduh aplikasi (Play Store / App Store) atau membuka versi web.
class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catering Booking'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Center(
              child: Column(
                children: const [
                  Text(
                    'Buat Pesanan Katering Sekarang!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aplikasi khusus untuk siswa SMK yang ingin memesan makanan praktis dan terjangkau.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Screenshot placeholder (could be replaced with real images later)
            Center(
              child: Container(
                width: 300,
                height: 600,
                color: Colors.grey.shade300,
                child: const Center(child: Text('Screenshot aplikasi')),
              ),
            ),
            const SizedBox(height: 32),
            // Keunggulan
            const Text(
              'Keunggulan:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const BulletPoint(text: 'Menu harian lengkap dengan foto'),
            const BulletPoint(text: 'Pembayaran via QRIS, VA, atau E‑Wallet'),
            const BulletPoint(text: 'Riwayat pesanan dan pelunasan hutang'),
            const BulletPoint(text: 'Akses admin untuk mengelola menu & data'),
            const SizedBox(height: 32),
            // CTA buttons
            Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: ganti dengan link Play Store yang sebenarnya.
                    },
                    icon: const Icon(Icons.android),
                    label: const Text('Google Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: ganti dengan link App Store yang sebenarnya.
                    },
                    icon: const Icon(Icons.apple),
                    label: const Text('App Store'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Buka versi web langsung.
                      // Menggunakan context.go ke home (sudah login) atau ke auth jika belum.
                      // Logika redirect ada di router.
                      // Di sini hanya navigasi.
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    icon: const Icon(Icons.web),
                    label: const Text('Gunakan di Web'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 16)),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
