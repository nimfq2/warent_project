import 'package:flutter/material.dart';
import '../../api/api_service.dart'; // <-- ИСПРАВЛЕНИЕ: Используем реальный API
import '../../app_theme.dart';
import '../../widgets/neon_button.dart';

class InfoEditorScreen extends StatefulWidget {
  const InfoEditorScreen({super.key});

  @override
  State<InfoEditorScreen> createState() => _InfoEditorScreenState();
}

class _InfoEditorScreenState extends State<InfoEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String _errorMessage = '';

  // Контроллеры для всех полей
  final _newsController = TextEditingController();
  final _baseRateController = TextEditingController();
  final _holdDaysController = TextEditingController();
  final _penaltyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      // --- ИСПРАВЛЕНИЕ: Вызываем реальный ApiService ---
      final info = await ApiService().getInfo();
      if(mounted) {
        _newsController.text = info['main_news'] ?? '';
        _baseRateController.text = info['base_rate_per_hour'].toString(); // Меняем ключ на per_hour
        _holdDaysController.text = info['hold_duration_days'].toString();
        _penaltyController.text = info['penalty_fee'].toString();
      }
    } catch (e) {
      _errorMessage = 'Ошибка загрузки данных: $e';
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _saveInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        final newInfo = {
          'main_news': _newsController.text,
          'base_rate_per_hour': double.tryParse(_baseRateController.text) ?? 0, // Меняем ключ на per_hour
          'hold_duration_days': int.tryParse(_holdDaysController.text) ?? 0,
          'penalty_fee': double.tryParse(_penaltyController.text) ?? 0,
          'bonuses': [], // TODO: Добавить интерфейс для редактирования бонусов
        };
        // --- ИСПРАВЛЕНИЕ: Вызываем реальный ApiService ---
        await ApiService().updateInfo(newInfo);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Информация успешно сохранена!'),
            backgroundColor: Colors.green,
          ));
        }
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.red,
          ));
        }
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _newsController.dispose();
    _baseRateController.dispose();
    _holdDaysController.dispose();
    _penaltyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор информации'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildSectionTitle('Главная новость'),
                      TextFormField(
                        controller: _newsController,
                        decoration: const InputDecoration(labelText: 'Текст новости', hintText: 'Оставьте пустым, чтобы скрыть'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSectionTitle('Основные тарифы'),
                      TextFormField(
                        controller: _baseRateController,
                        decoration: const InputDecoration(labelText: 'Базовая ставка, \$ / час', prefixText: '\$ '),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Введите число' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _holdDaysController,
                        decoration: const InputDecoration(labelText: 'Срок холда, дней'),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v) == null) ? 'Введите целое число' : null,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Штрафы'),
                      TextFormField(
                        controller: _penaltyController,
                        decoration: const InputDecoration(labelText: 'Штраф за досрочный слет, \$', prefixText: '\$ '),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Введите число' : null,
                      ),
                      const SizedBox(height: 32),
                      NeonButton(
                        text: _isLoading ? "Сохранение..." : "Сохранить изменения",
                        icon: Icons.save_outlined,
                        onPressed: _isLoading ? null : _saveInfo,
                      )
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}