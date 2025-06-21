import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../models/whatsapp_number.dart';
import '../../app_theme.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/app_icons.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;
  const UserDetailsScreen({required this.userId, super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Future<Map<String, dynamic>>? _userFuture;
  Future<List<WhatsAppNumber>>? _numbersFuture;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    setState(() {
      _userFuture = ApiService().getUserDetails(widget.userId);
      _numbersFuture = ApiService().getNumbersForUser(widget.userId);
    });
  }

  void _toggleUserStatus(bool currentStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(currentStatus ? 'Заблокировать пользователя?' : 'Разблокировать пользователя?'),
        content: const Text('Вы уверены, что хотите изменить статус этого пользователя?'),
        actions: [
          TextButton(child: const Text('Отмена'), onPressed: () => Navigator.of(ctx).pop(false)),
          ElevatedButton(
            child: const Text('Подтвердить'),
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService().updateUserStatus(widget.userId, !currentStatus);
        _loadAllData();
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка: $e"), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль пользователя'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllData),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Не удалось загрузить данные.'));
          }

          final user = snapshot.data!;
          final bool isActive = user['is_active'];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(user['email'], style: Theme.of(context).textTheme.titleLarge)),
                          Chip(
                            label: Text(isActive ? 'Активен' : 'Заблокирован', style: const TextStyle(color: Colors.white)),
                            backgroundColor: isActive ? Colors.green : Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                       _buildDetailRow('ID пользователя:', user['id'].toString()),
                       _buildDetailRow('Telegram ID:', user['telegram_user_id'] ?? 'Не привязан'),
                       _buildDetailRow('Баланс:', '\$${user['balance'].toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Номера пользователя', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              
              _buildNumbersList(),

              const SizedBox(height: 24),

              NeonButton(
                text: isActive ? 'Заблокировать' : 'Разблокировать',
                icon: isActive ? Icons.lock_outline : Icons.lock_open_outlined,
                onPressed: () => _toggleUserStatus(isActive),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: AppTheme.secondaryFontColor))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNumbersList() {
    return FutureBuilder<List<WhatsAppNumber>>(
      future: _numbersFuture,
      builder: (context, numbersSnapshot) {
        if (numbersSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (numbersSnapshot.hasError || !numbersSnapshot.hasData || numbersSnapshot.data!.isEmpty) {
          return const Card(child: ListTile(title: Text("У этого пользователя нет номеров.")));
        }
        final numbers = numbersSnapshot.data!;
        
        return Card(
          child: Column(
            children: numbers.map((number) => ListTile(
              leading: const Icon(AppIcons.phone),
              title: Text(number.phoneNumber),
              subtitle: Text("Статус: ${number.status}"),
            )).toList(),
          ),
        );
      },
    );
  }
}