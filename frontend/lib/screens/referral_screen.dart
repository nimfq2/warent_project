import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/api_service.dart';
import '../app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/app_icons.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  late Future<Map<String, dynamic>> _referralFuture;

  @override
  void initState() {
    super.initState();
    _referralFuture = ApiService().getReferralInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Реферальная система'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _referralFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Функционал в разработке"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Не удалось загрузить информацию.'));
          }

          final referralInfo = snapshot.data!;
          final referralLink = referralInfo['referral_link'];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Icon(AppIcons.users, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Приглашайте друзей и зарабатывайте!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Получайте бонус за каждый успешно сданный номер вашими друзьями.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.secondaryFontColor),
              ),
              const SizedBox(height: 24),
              _buildReferralLinkCard(context, referralLink),
              const SizedBox(height: 24),
              _buildReferralStats(
                invitedCount: referralInfo['invited_users_count'],
                totalEarnings: (referralInfo['total_earnings'] as num).toDouble(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReferralLinkCard(BuildContext context, String link) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Ваша персональная ссылка для приглашений:', style: TextStyle(color: AppTheme.secondaryFontColor)),
            const SizedBox(height: 8),
            SelectableText(
              link,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            NeonButton(
              text: 'Копировать ссылку',
              icon: AppIcons.link,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Ссылка скопирована!'), backgroundColor: Colors.green),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReferralStats({required int invitedCount, required double totalEarnings}) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Приглашено', invitedCount.toString(), AppIcons.users)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Заработано', '\$${totalEarnings.toStringAsFixed(2)}', AppIcons.dollar_sign)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.secondaryFontColor),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: AppTheme.secondaryFontColor)),
          ],
        ),
      ),
    );
  }
}