import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../app_theme.dart';
import './user_details_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _usersFuture = ApiService().getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все пользователи'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        color: AppTheme.primaryColor,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Center(child: Text("Ошибка: ${snapshot.error}"));
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Пользователи не найдены.'));
            
            final users = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: users.length,
              itemBuilder: (ctx, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute(builder: (ctx) => UserDetailsScreen(userId: user['id'])),
                      ).then((_) => _loadUsers());
                    },
                    leading: CircleAvatar(backgroundColor: AppTheme.cardColor, child: Text(user['id'].toString())),
                    title: Text(user['email']),
                    subtitle: Text('TG ID: ${user['telegram_user_id'] ?? 'N/A'}'),
                    trailing: Tooltip(
                      message: user['is_active'] ? 'Active' : 'Blocked',
                      child: Icon(
                        user['is_active'] ? Icons.check_circle : Icons.cancel,
                        color: user['is_active'] ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}