import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_service.dart';
import '../providers/auth_provider.dart';
import '../app_theme.dart';
import '../widgets/app_icons.dart';

import './admin/admin_numbers_screen.dart';
import './admin/admin_profile_screen.dart';
import './admin/info_editor_screen.dart';
import './admin/user_list_screen.dart';
import './admin/user_details_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Future<Map<String, int>>? _statsFuture;
  Future<List<Map<String, dynamic>>>? _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _statsFuture = ApiService().getAdminDashboardStats();
      _usersFuture = ApiService().getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Панель управления'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить', onPressed: _loadAllData),
          IconButton(
            icon: const Icon(AppIcons.user),
            tooltip: 'Профиль и Баланс',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const AdminProfileScreen()));
            },
          ),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Выйти',
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: AppTheme.primaryColor,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildStatsSection(),
            const SizedBox(height: 24),
            Text('Быстрые действия', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Последние пользователи', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const UserListScreen()));
                  },
                  child: const Text('Все'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildUserList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return FutureBuilder<Map<String, int>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) return const Center(child: Text("Не удалось загрузить статистику"));
        final stats = snapshot.data!;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _StatCard(title: 'Всего юзеров', value: stats['total_users'].toString(), icon: AppIcons.users, color: Colors.blue),
            _StatCard(title: 'Активные номера', value: stats['active_numbers'].toString(), icon: AppIcons.phone, color: Colors.green),
            _StatCard(title: 'Номера в очереди', value: stats['queued_numbers'].toString(), icon: Icons.hourglass_top, color: Colors.orange),
            _StatCard(title: 'В бане', value: stats['banned_numbers'].toString(), icon: Icons.gpp_bad, color: Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(AppIcons.phone),
          title: const Text('Управление номерами'),
          subtitle: const Text('Отправить коды, завершить аренду'),
          trailing: const Icon(AppIcons.arrow_right, size: 16),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const AdminNumbersScreen()));
          },
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(AppIcons.edit),
          title: const Text('Настроить инфо-окно'),
          subtitle: const Text('Изменить тарифы, бонусы и новости'),
          trailing: const Icon(AppIcons.arrow_right, size: 16),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const InfoEditorScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildUserList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Нет пользователей"));
        final users = snapshot.data!;
        return Column(
          children: users.take(5).map((user) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: ListTile(
              onTap: () {
                Navigator.of(context).push<void>(MaterialPageRoute(builder: (ctx) => UserDetailsScreen(userId: user['id']))).then((_) => _loadAllData());
              },
              leading: CircleAvatar(backgroundColor: AppTheme.cardColor, child: Text(user['id'].toString())),
              title: Text(user['email']),
              trailing: Icon(
                user['is_active'] ? Icons.check_circle : Icons.cancel,
                color: user['is_active'] ? Colors.green : Colors.red,
              ),
            ),
          )).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}