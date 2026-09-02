import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PackItem {
  final String id;
  String name;
  String category;
  int quantity;
  bool isPacked;

  PackItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isPacked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'isPacked': isPacked,
      };

  static PackItem fromJson(Map<String, dynamic> j) => PackItem(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        category: (j['category'] ?? 'Разное').toString(),
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        isPacked: j['isPacked'] == true,
      );
}

class Trip {
  final String id;
  String name;
  String destination;
  String tripType; // weekend, beach, business, nature
  int days;
  final List<PackItem> items;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.tripType,
    this.days = 3,
    List<PackItem>? items,
  }) : items = items ?? [];

  int get totalItems => items.length;
  int get packedItems => items.where((i) => i.isPacked).length;
  double get progress => totalItems == 0 ? 0.0 : packedItems / totalItems;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'destination': destination,
        'tripType': tripType,
        'days': days,
        'items': items.map((i) => i.toJson()).toList(),
      };

  static Trip fromJson(Map<String, dynamic> j) => Trip(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? 'Поездка').toString(),
        destination: (j['destination'] ?? '').toString(),
        tripType: (j['tripType'] ?? 'weekend').toString(),
        days: (j['days'] as num?)?.toInt() ?? 3,
        items: (j['items'] as List? ?? [])
            .map((e) => PackItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PackStore extends ChangeNotifier {
  static const _tripsKey = 'packpilot_trips_v1';

  final List<Trip> _trips = [];
  bool _ready = false;
  Trip? _activeTrip;

  bool get ready => _ready;
  List<Trip> get trips => List.unmodifiable(_trips);
  Trip get activeTrip => _activeTrip ?? _trips.first;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_tripsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _trips.clear();
        for (final item in list) {
          _trips.add(Trip.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (_) {}

    if (_trips.isEmpty) {
      _seedDemoTrips();
    }

    _activeTrip = _trips.first;
    _ready = true;
    notifyListeners();
  }

  void _seedDemoTrips() {
    _trips.clear();
    _trips.add(
      Trip(
        id: 't1',
        name: 'Поездка в Стамбул',
        destination: 'Турция',
        tripType: 'weekend',
        days: 4,
        items: [
          PackItem(id: 'i1', name: 'Загранпаспорт и страховка', category: 'Документы', isPacked: true),
          PackItem(id: 'i2', name: 'Банковские карты и лиры', category: 'Документы', isPacked: true),
          PackItem(id: 'i3', name: 'Смартфон и зарядка', category: 'Гаджеты', isPacked: true),
          PackItem(id: 'i4', name: 'Пауэрбанк 20000 mAh', category: 'Гаджеты', isPacked: false),
          PackItem(id: 'i5', name: 'Удобные кроссовки', category: 'Одежда', isPacked: true),
          PackItem(id: 'i6', name: 'Ветровка от дождя', category: 'Одежда', isPacked: false),
          PackItem(id: 'i7', name: 'Аптечка первой помощи', category: 'Аптечка', isPacked: false),
        ],
      ),
    );
  }

  void selectTrip(Trip trip) {
    _activeTrip = trip;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tripsKey, jsonEncode(_trips.map((t) => t.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> createTrip(String name, String destination, String type, int days) async {
    final items = _generateItemsForType(type, days);
    final trip = Trip(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      destination: destination.trim(),
      tripType: type,
      days: days,
      items: items,
    );
    _trips.add(trip);
    _activeTrip = trip;
    notifyListeners();
    await _persist();
  }

  List<PackItem> _generateItemsForType(String type, int days) {
    final list = <PackItem>[
      PackItem(id: 'g1', name: 'Паспорт и билеты', category: 'Документы'),
      PackItem(id: 'g2', name: 'Смартфон и зарядный провод', category: 'Гаджеты'),
      PackItem(id: 'g3', name: 'Комплект белья ($days шт)', category: 'Одежда', quantity: days),
      PackItem(id: 'g4', name: 'Футболки ($days шт)', category: 'Одежда', quantity: days),
      PackItem(id: 'g5', name: 'Зубная щетка и паста', category: 'Гигиена'),
    ];

    if (type == 'beach') {
      list.addAll([
        PackItem(id: 'b1', name: 'Солнцезащитный крем SPF 50', category: 'Гигиена'),
        PackItem(id: 'b2', name: 'Плавательный костюм', category: 'Одежда', quantity: 2),
        PackItem(id: 'b3', name: 'Солнечные очки', category: 'Одежда'),
      ]);
    } else if (type == 'business') {
      list.addAll([
        PackItem(id: 'bu1', name: 'Ноутбук и блок питания', category: 'Гаджеты'),
        PackItem(id: 'bu2', name: 'Рубашка и брюки', category: 'Одежда', quantity: 2),
      ]);
    }

    return list;
  }

  Future<void> toggleItem(PackItem item) async {
    item.isPacked = !item.isPacked;
    notifyListeners();
    await _persist();
  }

  Future<void> addItem(String name, String category, int qty) async {
    if (_activeTrip == null) return;
    _activeTrip!.items.add(PackItem(
      id: 'i_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      category: category,
      quantity: qty,
    ));
    notifyListeners();
    await _persist();
  }

  Future<void> deleteTrip(Trip trip) async {
    _trips.removeWhere((t) => t.id == trip.id);
    if (_activeTrip?.id == trip.id) {
      _activeTrip = _trips.isNotEmpty ? _trips.first : null;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> resetAll() async {
    _trips.clear();
    _seedDemoTrips();
    _activeTrip = _trips.first;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tripsKey);
    } catch (_) {}
  }
}

class PackScope extends InheritedNotifier<PackStore> {
  const PackScope({super.key, required PackStore store, required super.child})
      : super(notifier: store);

  static PackStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PackScope>();
    assert(scope != null, 'PackScope not found');
    return scope!.notifier!;
  }
}
