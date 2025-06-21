import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../app_theme.dart';
import '../widgets/neon_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _walletController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
  }

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletAddress() async {
    setState(() { _isLoading = true; });
    try {
      final address = await ApiService().getWalletAddress();
      if (mounted) {
        setState(() {
          _walletController.text = address ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() { _isLoading = false; });
      // TODO: Показать ошибку
    }
  }

  Future<void> _saveWalletAddress() async {
    final newAddress = _walletController.text;
    if (newAddress.isEmpty) return;
    setState(() { _isLoading = true; });
    try {
      await ApiService().updateWalletAddress(newAddress);
      await _loadWalletAddress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Адрес сохранен!'), backgroundColor: Colors.green));
      }
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль и выплаты')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(Icons.telegram, size: 32),
                  title: const Text('Ваш Telegram ID', style: TextStyle(color: AppTheme.secondaryFontColor)),
                  subtitle: const Text('54321', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 24),
                Text('Платежная информация', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Выплаты производятся на ваш кошелек CryptoBot в сети TRC-20 (USDT).', style: TextStyle(color: AppTheme.secondaryFontColor)),
                const SizedBox(height: 16),
                TextField(
                  controller: _walletController,
                  decoration: const InputDecoration(labelText: 'Ваш ID или адрес TRC-20 USDT', hintText: 'Например, @username или T...'),
                ),
                const SizedBox(height: 24),
                NeonButton(text: 'Сохранить адрес', icon: Icons.save_outlined, onPressed: _isLoading ? null : _saveWalletAddress),
              ],
            ),
    );
  }
}