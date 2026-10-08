import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import 'demo_state.dart';
import 'shared_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const List<_WeeklyMenuItem> _weeklyMenus = [
    _WeeklyMenuItem(
      date: 'Senin, 27 Okt',
      title: 'Nasi Liwet Ayam Goreng',
      subtitle: 'Tempe goreng, sambal',
    ),
    _WeeklyMenuItem(
      date: 'Selasa, 28 Okt',
      title: 'Ayam Telur Asin',
      subtitle: 'Martabak tahu, kacang panjang',
    ),
    _WeeklyMenuItem(
      date: 'Rabu, 29 Okt',
      title: 'Ayam Hot Lava',
      subtitle: 'Tahu krispi, timun',
    ),
    _WeeklyMenuItem(
      date: 'Kamis, 30 Okt',
      title: 'Ayam Teriyaki',
      subtitle: 'Nasi, sayuran, wijen',
    ),
    _WeeklyMenuItem(
      date: 'Jumat, 31 Okt',
      title: 'Nasi Goreng Spesial',
      subtitle: 'Telur, ayam suwir, kerupuk',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
          children: [
            const DemoTopBar(),
            const SizedBox(height: 8),
            Text(
              'WELCOME',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              'Hellow, Humiiu!',
              style: AppTextStyles.welcome.copyWith(
                fontSize: 29,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _DebtCard(
              onTap: () {
                ref.read(demoOrderProvider).prepareDebtPayment(60000);
                context.push('/checkout');
              },
            ),
            const SizedBox(height: 26),
            DemoSectionTitle(
              title: 'Weekly Menu',
              trailing: TextButton(
                onPressed: () => context.go('/order'),
                child: const Text('See All ›'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: PageView.builder(
                padEnds: false,
                controller: PageController(viewportFraction: 0.88),
                itemCount: _weeklyMenus.length,
                itemBuilder: (context, index) {
                  final item = _weeklyMenus[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == _weeklyMenus.length - 1 ? 0 : 16,
                    ),
                    child: _MenuCard(
                      date: item.date,
                      title: item.title,
                      subtitle: item.subtitle,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            _PreferenceCard(
              onTap: () => context.go('/profile'),
            ),
            const SizedBox(height: 24),
            DemoPrimaryButton(
              label: 'Start Buying!',
              onPressed: () => context.go('/order'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _WeeklyMenuItem {
  final String date;
  final String title;
  final String subtitle;

  const _WeeklyMenuItem({
    required this.date,
    required this.title,
    required this.subtitle,
  });
}

class _DebtCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DebtCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'DEBT LEFT',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                width: 34,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.circle, color: AppColors.primary, size: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTextStyles.priceLarge.copyWith(fontSize: 42),
              children: const [
                TextSpan(
                  text: 'Rp ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                TextSpan(text: '60.000'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DemoPrimaryButton(
            label: 'Pay Now',
            icon: Icons.arrow_forward,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String date;
  final String title;
  final String subtitle;

  const _MenuCard({
    required this.date,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 232,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFDEA5), Color(0xFFFFEBCB)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(date, style: AppTextStyles.caption),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyMediumBold),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PreferenceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.star_border,
                color: AppColors.iconGold, size: 35),
          ),
          const SizedBox(height: 16),
          Text(
            'Punya request khusus?',
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'Beri tahu kami jika ada alergi atau\nsaran makanan untuk pesanan\nAnda berikutnya.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onTap,
            child: const Text('Atur Preferensi'),
          ),
        ],
      ),
    );
  }
}
