import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BillingUnit { month, year }

enum AnchorRule { dayOfMonth, lastDay, nthWeekday }

enum SubscriptionStatus { active, due, overdue, paused, cancelled }

class Subscription {
  final String id;
  final String userId;
  final String name;
  final String? providerId;
  final String? iconUrl;
  final int priceUsdCents;
  final BillingUnit unit;
  final int interval;
  final AnchorRule anchorRule;
  final DateTime startDateUtc;
  final DateTime nextBillDateUtc;
  final SubscriptionStatus status;
  final int reminderDaysBefore;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime lastUpdatedUtc;
  final bool deleted;

  Subscription({
    String? id,
    required this.userId,
    required this.name,
    this.providerId,
    this.iconUrl,
    required this.priceUsdCents,
    required this.interval,
    required this.unit,
    required this.anchorRule,
    required this.startDateUtc,
    required this.nextBillDateUtc,
    required this.status,
    required this.reminderDaysBefore,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    DateTime? lastUpdatedUtc,
    this.deleted = false,
  }) : id = id ?? const Uuid().v4(),
       createdAtUtc = (createdAtUtc ?? DateTime.now()).toUtc(),
       updatedAtUtc = (updatedAtUtc ?? DateTime.now()).toUtc(),
       lastUpdatedUtc = (lastUpdatedUtc ?? DateTime.now()).toUtc();

  // ---------- Utility: Safe date parsing ----------
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now().toUtc();
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    if (value is String) {
      try {
        return DateTime.parse(value).toUtc();
      } catch (_) {
        return DateTime.now().toUtc();
      }
    }
    return DateTime.now().toUtc();
  }

  // ---------- Utility: Enum parser ----------
  static T _enumFromString<T>(Iterable<T> values, String? name, T fallback) {
    if (name == null) return fallback;
    try {
      return values.firstWhere((e) => e.toString().split('.').last == name);
    } catch (_) {
      return fallback;
    }
  }

  // ---------- Firestore to Model ----------
  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as String? ?? const Uuid().v4(),
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? 'Unnamed',
      providerId: map['providerId'] as String?,
      iconUrl: map['iconUrl'] as String?,
      priceUsdCents:
          (map['priceUsdCents'] is int)
              ? map['priceUsdCents'] as int
              : int.tryParse(map['priceUsdCents']?.toString() ?? '') ?? 0,
      interval:
          (map['interval'] is int)
              ? map['interval'] as int
              : int.tryParse(map['interval']?.toString() ?? '') ?? 1,
      unit: _enumFromString<BillingUnit>(
        BillingUnit.values,
        map['unit'] as String?,
        BillingUnit.month,
      ),
      anchorRule: _enumFromString<AnchorRule>(
        AnchorRule.values,
        map['anchorRule'] as String?,
        AnchorRule.dayOfMonth,
      ),
      startDateUtc: _parseDate(map['startDateUtc']),
      nextBillDateUtc: _parseDate(map['nextBillDateUtc']),
      status: _enumFromString<SubscriptionStatus>(
        SubscriptionStatus.values,
        map['status'] as String?,
        SubscriptionStatus.active,
      ),
      reminderDaysBefore:
          (map['reminderDaysBefore'] is int)
              ? map['reminderDaysBefore'] as int
              : int.tryParse(map['reminderDaysBefore']?.toString() ?? '') ?? 3,
      createdAtUtc: _parseDate(map['createdAtUtc']),
      updatedAtUtc: _parseDate(map['updatedAtUtc']),
      lastUpdatedUtc: _parseDate(map['lastUpdatedUtc']),
      deleted: map['deleted'] as bool? ?? false,
    );
  }

  // ---------- Model to Firestore ----------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'providerId': providerId,
      'iconUrl': iconUrl,
      'priceUsdCents': priceUsdCents,
      'interval': interval,
      'unit': unit.name,
      'anchorRule': anchorRule.name,
      'startDateUtc': Timestamp.fromDate(startDateUtc.toUtc()),
      'nextBillDateUtc': Timestamp.fromDate(nextBillDateUtc.toUtc()),
      'status': status.name,
      'reminderDaysBefore': reminderDaysBefore,
      'createdAtUtc': Timestamp.fromDate(createdAtUtc.toUtc()),
      'updatedAtUtc': Timestamp.fromDate(updatedAtUtc.toUtc()),
      'lastUpdatedUtc': Timestamp.fromDate(lastUpdatedUtc.toUtc()),
      'deleted': deleted,
    };
  }

  // ---------- Copy method ----------
  Subscription copyWith({
    String? id,
    String? userId,
    String? name,
    String? providerId,
    String? iconUrl,
    int? priceUsdCents,
    int? interval,
    BillingUnit? unit,
    AnchorRule? anchorRule,
    DateTime? startDateUtc,
    DateTime? nextBillDateUtc,
    SubscriptionStatus? status,
    int? reminderDaysBefore,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    DateTime? lastUpdatedUtc,
    bool? deleted,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      providerId: providerId ?? this.providerId,
      iconUrl: iconUrl ?? this.iconUrl,
      priceUsdCents: priceUsdCents ?? this.priceUsdCents,
      interval: interval ?? this.interval,
      unit: unit ?? this.unit,
      anchorRule: anchorRule ?? this.anchorRule,
      startDateUtc: startDateUtc ?? this.startDateUtc,
      nextBillDateUtc: nextBillDateUtc ?? this.nextBillDateUtc,
      status: status ?? this.status,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? DateTime.now().toUtc(),
      lastUpdatedUtc: lastUpdatedUtc ?? DateTime.now().toUtc(),
      deleted: deleted ?? this.deleted,
    );
  }

  double get priceUsd => priceUsdCents / 100.0;

  @override
  String toString() {
    return 'Subscription(id: $id, name: $name, price: $priceUsd, nextBill: $nextBillDateUtc, status: $status, deleted: $deleted)';
  }
}
