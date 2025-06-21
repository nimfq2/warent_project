class ArchiveEntry {
  final String phoneNumber;
  final String status;
  final DateTime date;
  final String lifetime;
  final double payout;
  final String? payoutCheck;
  final double referralBonus;

  ArchiveEntry({
    required this.phoneNumber,
    required this.status,
    required this.date,
    required this.lifetime,
    required this.payout,
    this.payoutCheck,
    this.referralBonus = 0.0,
  });

  // Этот метод пока не используется, так как ApiService возвращает заглушку,
  // но он понадобится, когда мы реализуем API для архива на бэкенде.
  factory ArchiveEntry.fromJson(Map<String, dynamic> json) {
    return ArchiveEntry(
      phoneNumber: json['phone_number'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      lifetime: json['lifetime'],
      payout: (json['payout'] as num).toDouble(),
      payoutCheck: json['payout_check'],
      referralBonus: (json['referral_bonus'] as num? ?? 0.0).toDouble(),
    );
  }
}