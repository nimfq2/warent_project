import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../app_theme.dart';
import '../widgets/app_icons.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late Future<Map<String, dynamic>> _infoFuture;

  @override
  void initState() {
    super.initState();
    _infoFuture = ApiService().getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _infoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Не удалось загрузить информацию.'));
          }

          final info = snapshot.data!;
          final bonuses = (info['bonuses'] as List? ?? []).cast<Map<String, dynamic>>();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info['main_news'] != null && info['main_news'].isNotEmpty) ...[
                  _buildNewsCard(info['main_news']),
                  const SizedBox(height: 24),
                ],
                Text('Тарифы и условия', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildPriceCard('Базовая ставка', '\$${(info['base_rate_per_day'] ?? 0).toStringAsFixed(2)} / день', Icons.monetization_on_outlined, Colors.green),
                const SizedBox(height: 12),
                _buildPriceCard('Срок холда', '${info['hold_duration_days'] ?? 0} дней', Icons.timer_outlined, Colors.blue),
                const SizedBox(height: 24),
                Text('Бонусы за долгосрочную работу', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (bonuses.isNotEmpty)
                  for (var bonus in bonuses)
                    _buildBonusTile('Более ${bonus['threshold_days']} дней', '+ \$${(bonus['bonus_per_day'] ?? 0).toStringAsFixed(2)} / день')
                else
                  const Text("Бонусы в данный момент не предусмотрены.", style: TextStyle(color: AppTheme.secondaryFontColor)),
                const Divider(height: 32, color: AppTheme.cardColor),
                Text('Штрафы', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _buildPriceCard('Штраф за досрочный слет', '\$${(info['penalty_fee'] ?? 0).toStringAsFixed(2)}', Icons.gavel_rounded, Colors.red, isSmall: true),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(String news) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5))
      ),
      child: Row(
        children: [
          const Icon(AppIcons.info, color: AppTheme.primaryColor, size: 32),
          const SizedBox(width: 16),
          Expanded(child: Text(news, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String title, String value, IconData icon, Color color, {bool isSmall = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: isSmall ? 28 : 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: TextStyle(fontSize: isSmall ? 18 : 24, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildBonusTile(String condition, String reward) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: const Icon(Icons.star_border, color: Colors.orange),
      title: Text(condition),
      subtitle: Text(reward, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
    );
  }
}