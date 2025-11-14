import 'package:uuid/uuid.dart';

enum BillingUnit { month, year }

class Provider {
  final String id;
  final String name;
  final int interval;
  final int defaultPriceUsdCents;
  final BillingUnit unit;
  final String iconAsset;

  Provider({
    String? id,
    required this.name,
    required this.defaultPriceUsdCents,
    required this.iconAsset,
    required this.unit,
    required this.interval,
  }) : id = id ?? Uuid().v4();

  factory Provider.fromMap(Map<String, dynamic> map) {
    return Provider(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: map['name'],
      defaultPriceUsdCents: map['defaultPriceUsdCents'],
      iconAsset: map['iconAsset'],
      unit: BillingUnit.values.firstWhere(
        (e) => e.name == (map['unit'] ?? 'month'),
      ),
      interval: map['interval'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'defaultPriceUsdCents': defaultPriceUsdCents,
      'iconAsset': iconAsset,
      'unit': unit.name,
      'interval': interval,
    };
  }

  Provider copyWith({
    String? id,
    String? name,
    int? defaultPriceUsdCents,
    String? iconAsset,
    BillingUnit? unit,
    int? interval,
  }) {
    return Provider(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultPriceUsdCents: defaultPriceUsdCents ?? this.defaultPriceUsdCents,
      iconAsset: iconAsset ?? this.iconAsset,
      unit: unit ?? this.unit,
      interval: interval ?? this.interval,
    );
  }
}
