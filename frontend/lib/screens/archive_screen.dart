import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';
import '../models/archive_entry.dart';
import '../app_theme.dart';
import '../widgets/app_icons.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late Future<List<ArchiveEntry>> _archiveFuture;

  @override
  void initState() {
    super.initState();
    _loadArchive();
  }
  
  void _loadArchive() {
    setState(() {
      _archiveFuture = ApiService().getArchive();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Архив'),
      ),
      body: FutureBuilder<List<ArchiveEntry>>(
        future: _archiveFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Функционал в разработке"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Ваш архив пуст.'));
          }

          final archiveEntries = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: archiveEntries.length,
            itemBuilder: (ctx, index) {
              final entry = archiveEntries[index];
              final isSuccess = entry.status == 'successful';
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                child: ExpansionTile(
                  iconColor: AppTheme.primaryColor,
                  collapsedIconColor: AppTheme.secondaryFontColor,
                  leading: Icon(
                    isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                  title: Text(entry.phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    isSuccess ? 'Успешно' : 'Слет',
                    style: TextStyle(color: isSuccess ? Colors.green.shade300 : Colors.red.shade300),
                  ),
                  trailing: const Icon(AppIcons.arrow_right, size: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).copyWith(bottom: 16),
                      child: Column(
                        children: [
                          _buildDetailRow('Дата:', DateFormat('dd.MM.yyyy HH:mm').format(entry.date)),
                          _buildDetailRow('Время жизни:', entry.lifetime),
                          _buildDetailRow('Выплата:', '\$${entry.payout.toStringAsFixed(2)}'),
                          if (entry.referralBonus > 0)
                            _buildDetailRow('Реф. бонус:', '\$${entry.referralBonus.toStringAsFixed(2)}'),
                          if (entry.payoutCheck != null)
                            _buildDetailRow('Чек выплаты:', entry.payoutCheck!),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.secondaryFontColor)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}