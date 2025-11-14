import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentEvent {
  final String id;
  final String subscriptionId;
  final DateTime paidAtUtc;
  final int amountUsdCents;
  final DateTime createdAtUtc;

  PaymentEvent({
    String? id,
    required this.subscriptionId,
    required this.paidAtUtc,
    required this.amountUsdCents,
    DateTime? createdAtUtc,
  }) : id = id ?? const Uuid().v4(),
       createdAtUtc = (createdAtUtc ?? DateTime.now()).toUtc();

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now().toUtc();
    if (v is Timestamp) return v.toDate().toUtc();
    if (v is DateTime) return v.toUtc();
    if (v is String) return DateTime.parse(v).toUtc();
    return DateTime.now().toUtc();
  }

  factory PaymentEvent.fromMap(Map<String, dynamic> map) {
    return PaymentEvent(
      id: map['id'] as String? ?? const Uuid().v4(),
      subscriptionId: map['subscriptionId'] as String? ?? '',
      paidAtUtc: _parseDate(map['paidAtUtc']),
      amountUsdCents: map['amountUsdCents'] ?? 0,
      createdAtUtc: _parseDate(map['createdAtUtc']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'paidAtUtc': Timestamp.fromDate(paidAtUtc.toUtc()),
      'amountUsdCents': amountUsdCents,
      'createdAtUtc': Timestamp.fromDate(createdAtUtc.toUtc()),
    };
  }

  PaymentEvent copyWith({
    String? id,
    String? subscriptionId,
    DateTime? paidAtUtc,
    int? amountUsdCents,
    DateTime? createdAtUtc,
  }) {
    return PaymentEvent(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      paidAtUtc: paidAtUtc ?? this.paidAtUtc,
      amountUsdCents: amountUsdCents ?? this.amountUsdCents,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return 'PaymentEvent(id: $id, subId: $subscriptionId, paidAt: $paidAtUtc, amount: $amountUsdCents)';
  }
}
