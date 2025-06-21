import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/app_icons.dart';

import './numbers_screen.dart';
import './statistics_screen.dart';
import './archive_screen.dart';
import './profile_screen.dart';
import './info_screen.dart';
import './referral_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Добро пожаловать!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text('Управляйте вашими номерами и финансами.', style: TextStyle(color: AppTheme.secondaryFontColor, fontSize: 16)),
          const SizedBox(height: 24),

          _buildBalanceCard(context),
          const SizedBox(height: 24),

          _buildMenuItem(context: context, icon: AppIcons.phone, title: 'Мои номера', subtitle: 'Просмотр, добавление и управление', screen: const NumbersScreen()),
          _buildMenuItem(context: context, icon: AppIcons.bar_chart, title: 'Статистика', subtitle: 'Ваши успехи, слеты и доходы', screen: const StatisticsScreen()),
          _buildMenuItem(context: context, icon: AppIcons.users, title: 'Реферальная система', subtitle: 'Приглашайте друзей и зарабатывайте', screen: const ReferralScreen()),
          _buildMenuItem(context: context, icon: AppIcons.archive, title: 'Архив', subtitle: 'История всех завершенных операций', screen: const ArchiveScreen()),
          _buildMenuItem(context: context, icon: AppIcons.info, title: 'Информация', subtitle: 'Тарифы, условия и новости', screen: const InfoScreen()),
        ],
      ),
    );
  }
  
  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Баланс', style: TextStyle(color: AppTheme.secondaryFontColor, fontSize: 16)),
              SizedBox(height: 4),
              Text('145.75 \$', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          NeonButton(text: 'Вывести', onPressed: () {})
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => screen)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(icon, size: 28, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: Text(subtitle),
        trailing: const Icon(AppIcons.arrow_right, size: 16, color: AppTheme.secondaryFontColor),
      ),
    );
  }
}