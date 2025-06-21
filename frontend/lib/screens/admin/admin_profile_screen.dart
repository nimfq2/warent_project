import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../app_theme.dart';
import '../../widgets/app_icons.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  late Future<List<Map<String, String>>> _balanceFuture;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  void _loadBalance() {
    setState(() {
      _balanceFuture = ApiService().getCryptoBotBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль и Баланс'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить баланс',
            onPressed: _loadBalance,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadBalance(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(Icons.shield_outlined, size: 32),
              title: const Text("Ваш Telegram ID (Admin)", style: TextStyle(color: AppTheme.secondaryFontColor)),
              subtitle: const Text("12345678", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            Text('Баланс кошелька CryptoBot', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Это актуальный баланс вашего приложения в Crypto Pay.',
              style: TextStyle(color: AppTheme.secondaryFontColor),
            ),
            const SizedBox(height: 16),
            _buildBalanceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceList() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _balanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки баланса: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Не удалось получить данные о балансе.'));
        }

        final balances = snapshot.data!;

        return Column(
          children: balances.map((balance) {
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: _getCurrencyColor(balance['currency_code']!),
                  child: Text(
                    balance['currency_code']!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                title: Text(
                  balance['available']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                subtitle: const Text('Доступно'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getCurrencyColor(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USDT': return Colors.green.shade700;
      case 'TON': return Colors.blue.shade700;
      case 'BTC': return Colors.orange.shade800;
      default: return Colors.grey.shade800;
    }
  }
}