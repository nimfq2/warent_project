import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/app_icons.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTotalStatsCard(),
          const SizedBox(height: 24),
          _buildDetailedStatsGrid(context),
        ],
      ),
    );
  }

  Widget _buildTotalStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTotalStatItem('Успешных', '15', Colors.green),
            const SizedBox(height: 60, child: VerticalDivider(color: AppTheme.backgroundColor, thickness: 2)),
            _buildTotalStatItem('Слетов', '1', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.secondaryFontColor)),
      ],
    );
  }

  Widget _buildDetailedStatsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard('В холде', '2', Icons.hourglass_full_outlined, context),
        _buildStatCard('Добавлено', '26', Icons.add_to_photos_outlined, context),
        _buildStatCard('Повторов', '3', Icons.replay_circle_filled_outlined, context),
        _buildStatCard('Пропущено', '5', Icons.skip_next_outlined, context),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: AppTheme.secondaryFontColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}