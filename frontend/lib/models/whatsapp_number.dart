import 'dart:typed_data';

class WhatsAppNumber {
  final int id;
  final String phoneNumber;
  final String status;
  final DateTime addedAt;
  final bool needsCodeInput;
  final Uint8List? imageBytes;
  
  // --- НОВЫЕ ПОЛЯ ---
  final DateTime? workStartedAt;
  final double currentEarnings;

  WhatsAppNumber({
    required this.id,
    required this.phoneNumber,
    required this.status,
    required this.addedAt,
    this.needsCodeInput = false,
    this.imageBytes,
    this.workStartedAt,
    this.currentEarnings = 0.0,
  });

  factory WhatsAppNumber.fromJson(Map<String, dynamic> json) {
    return WhatsAppNumber(
      id: json['id'],
      phoneNumber: json['phone_number'],
      status: json['status'],
      addedAt: DateTime.parse(json['added_at']),
      needsCodeInput: json['needs_code_input'] ?? false,
      workStartedAt: json['work_started_at'] != null ? DateTime.parse(json['work_started_at']) : null,
      currentEarnings: (json['current_earnings'] as num? ?? 0.0).toDouble(),
    );
  }
}