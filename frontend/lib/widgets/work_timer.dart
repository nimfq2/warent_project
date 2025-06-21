import 'dart:async';
import 'package:flutter/material.dart';

class WorkTimer extends StatefulWidget {
  final DateTime startTime;
  const WorkTimer({required this.startTime, super.key});

  @override
  State<WorkTimer> createState() => _WorkTimerState();
}

class _WorkTimerState extends State<WorkTimer> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Запускаем таймер, который обновляет UI каждую секунду
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    // Проверяем, что виджет все еще в дереве, чтобы избежать ошибок
    if (mounted) {
      setState(() {
        _elapsed = now.difference(widget.startTime);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Обязательно отменяем таймер при удалении виджета
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Форматируем продолжительность в вид ЧЧ:ММ:СС
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_elapsed.inHours);
    final minutes = twoDigits(_elapsed.inMinutes.remainder(60));
    final seconds = twoDigits(_elapsed.inSeconds.remainder(60));
    
    return Text(
      "$hours:$minutes:$seconds",
      style: const TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}