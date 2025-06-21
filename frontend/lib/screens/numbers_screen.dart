import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/whatsapp_number.dart';
import '../widgets/neon_button.dart';
import '../app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/work_timer.dart';

class NumbersScreen extends StatefulWidget {
  const NumbersScreen({super.key});

  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen> with TickerProviderStateMixin {
  late Future<List<WhatsAppNumber>> _numbersFuture;
  late TabController _tabController;
  List<WhatsAppNumber> _inQueueNumbers = [];
  List<WhatsAppNumber> _activeAndBannedNumbers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNumbers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNumbers() async {
    final future = ApiService().getNumbers();
    setState(() {
      _numbersFuture = future;
    });

    try {
      final allNumbers = await future;
      if (mounted) {
        setState(() {
          _inQueueNumbers = allNumbers.where((n) => n.status == 'queued' || n.status == 'pending_confirmation').toList();
          _activeAndBannedNumbers = allNumbers.where((n) => n.status == 'active' || n.status == 'banned').toList();
          final initialIndex = _tabController.index;
          _tabController.dispose();
          _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки номеров: $e')));
      }
    }
  }
  
  void _showAddNumberDialog() {
    final TextEditingController phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить новый номер'),
        content: TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Номер телефона'), keyboardType: TextInputType.phone),
        actions: [
          TextButton(child: const Text('Отмена'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            child: const Text('Добавить'),
            onPressed: () async {
              final phoneNumber = phoneController.text;
              if (phoneNumber.isEmpty) return;
              Navigator.of(ctx).pop();
              await ApiService().addNumber(phoneNumber);
              _loadNumbers();
            },
          ),
        ],
      ),
    );
  }

  void _showAppealDialog(int numberId) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Обжаловать слет'),
      content: const Text('Вы уверены, что аккаунт не заблокирован в WhatsApp? Администратор проверит статус номера вручную.'),
      actions: [
        TextButton(child: const Text('Отмена'), onPressed: () => Navigator.of(ctx).pop()),
        ElevatedButton(
          child: const Text('Обжаловать'),
          onPressed: () async {
            Navigator.of(ctx).pop();
            await ApiService().appealForNumber(numberId);
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Запрос на обжалование отправлен!'), backgroundColor: Colors.green));
            }
          },
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои номера'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNumbers)],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'В работе (${_activeAndBannedNumbers.length})'),
            Tab(text: 'В очереди (${_inQueueNumbers.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNumberDialog,
        tooltip: 'Добавить номер',
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNumbers,
        color: AppTheme.primaryColor,
        child: FutureBuilder<List<WhatsAppNumber>>(
          future: _numbersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Center(child: Text('Ошибка: ${snapshot.error}'));
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('У вас пока нет номеров.'));

            return TabBarView(
              controller: _tabController,
              children: [
                _buildNumbersList(_activeAndBannedNumbers),
                _buildNumbersList(_inQueueNumbers),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNumbersList(List<WhatsAppNumber> numbers) {
    if (numbers.isEmpty) {
      return Center(child: Text('В этом разделе номеров нет.', style: Theme.of(context).textTheme.bodySmall));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: numbers.length,
      itemBuilder: (ctx, index) {
        final number = numbers[index];
        if (number.status == 'pending_confirmation') {
          return _buildCodeInputCard(number);
        } else {
          return _buildNumberCard(number);
        }
      },
    );
  }

  Widget _buildCodeInputCard(WhatsAppNumber number) {
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.primaryColor)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(number.phoneNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Вам отправлено изображение с кодом!'),
            const SizedBox(height: 16),
            if (number.imageBytes != null)
              ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(number.imageBytes!, fit: BoxFit.contain))
            else
              const Center(child: Text("Изображение не найдено.")),
            const SizedBox(height: 16),
            NeonButton(
              text: 'Я подключил(а)',
              icon: Icons.check_circle_outline,
              onPressed: () async {
                await ApiService().confirmNumberConnection(number.id);
                _loadNumbers();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberCard(WhatsAppNumber number) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(_getStatusIcon(number.status), color: _getStatusColor(number.status)),
        title: Text(number.phoneNumber, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: number.status == 'active' && number.workStartedAt != null
            ? Row(
                children: [
                  const Text("В работе: "),
                  WorkTimer(startTime: number.workStartedAt!),
                  const Spacer(),
                  Text(
                    "~ \$${number.currentEarnings.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  )
                ],
              )
            : Text("Статус: ${number.status}"),
        trailing: _buildTrailingButton(number),
      ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active': return Icons.check_circle;
      case 'queued': return Icons.hourglass_top_outlined;
      case 'pending_confirmation': return AppIcons.phone;
      case 'banned': return Icons.gpp_bad_outlined;
      default: return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active': return Colors.green;
      case 'queued': return Colors.orange;
      case 'pending_confirmation': return AppTheme.primaryColor;
      case 'banned': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  Widget? _buildTrailingButton(WhatsAppNumber number) {
    if (number.status == 'queued') {
      return TextButton(onPressed: (){}, child: const Text('Удалить'));
    }
    if (number.status == 'banned') {
      return TextButton(child: const Text('Обжаловать'), onPressed: () => _showAppealDialog(number.id));
    }
    return null;
  }
}