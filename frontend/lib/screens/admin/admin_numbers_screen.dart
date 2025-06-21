import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../api/api_service.dart'; // Используем реальный API
import '../../models/whatsapp_number.dart';
import '../../app_theme.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/app_icons.dart';

class AdminNumbersScreen extends StatefulWidget {
  const AdminNumbersScreen({super.key});

  @override
  State<AdminNumbersScreen> createState() => _AdminNumbersScreenState();
}

class _AdminNumbersScreenState extends State<AdminNumbersScreen> {
  late Future<List<WhatsAppNumber>> _numbersFuture;

  @override
  void initState() {
    super.initState();
    _loadAllNumbers();
  }

  Future<void> _loadAllNumbers() {
    final future = ApiService().getAllNumbers();
    setState(() {
      _numbersFuture = future;
    });
    return future;
  }

  void _showSendImageDialog(WhatsAppNumber number) {
    Uint8List? selectedImageBytes;
    bool isSending = false;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text('Отправить картинку для\n${number.phoneNumber}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Загрузите изображение с кодом, которое будет отправлено пользователю.'),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    final image = await ImagePickerWeb.getImageAsBytes();
                    if (image != null) {
                      setDialogState(() {
                        selectedImageBytes = image;
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.secondaryFontColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: selectedImageBytes == null
                        ? const Center(child: Icon(Icons.add_a_photo_outlined, size: 40, color: AppTheme.secondaryFontColor))
                        : Image.memory(selectedImageBytes!, fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
              NeonButton(
                text: isSending ? 'Отправка...' : 'Отправить',
                onPressed: (selectedImageBytes != null && !isSending)
                    ? () async {
                        setDialogState(() => isSending = true);
                        try {
                          await ApiService().sendImageToUser(number.id, selectedImageBytes!);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Изображение отправлено'), backgroundColor: Colors.green),
                          );
                          _loadAllNumbers();
                        } catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка отправки: $e'), backgroundColor: Colors.red),
                          );
                        } finally {
                          if(mounted) setDialogState(() => isSending = false);
                        }
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление номерами'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllNumbers)],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllNumbers,
        color: AppTheme.primaryColor,
        child: FutureBuilder<List<WhatsAppNumber>>(
          future: _numbersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Center(child: Text("Ошибка: ${snapshot.error}"));
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('В системе нет номеров.'));
            
            final numbers = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: numbers.length,
              itemBuilder: (ctx, index) {
                final number = numbers[index];
                return Card(
                  child: ListTile(
                    leading: Icon(_getStatusIcon(number.status), color: _getStatusColor(number.status), size: 32),
                    title: Text(number.phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('Статус: ${number.status}'),
                    trailing: _buildActionButtonForAdmin(number),
                  ),
                );
              },
            );
          },
        ),
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

  Widget? _buildActionButtonForAdmin(WhatsAppNumber number) {
    if (number.status == 'queued') {
      return ElevatedButton(
        onPressed: () => _showSendImageDialog(number),
        child: const Text('Отправить код'),
      );
    }
    if (number.status == 'active' || number.status == 'pending_confirmation') {
       return ElevatedButton(
        onPressed: () { /* TODO: Логика завершения аренды и выплаты */ },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        child: const Text('Завершить'),
      );
    }
    return null;
  }
}