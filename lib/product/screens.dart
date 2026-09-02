import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import 'pack_store.dart';

IconData iconForTripType(String type) {
  return switch (type) {
    'beach' => Icons.beach_access_rounded,
    'business' => Icons.business_center_rounded,
    'nature' => Icons.terrain_rounded,
    _ => Icons.location_city_rounded,
  };
}

/// Экран 1. Список поездок
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key, required this.onOpenPackList});

  final VoidCallback onOpenPackList;

  @override
  Widget build(BuildContext context) {
    final store = PackScope.of(context);
    final trips = store.trips;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PackPilot', style: AppTheme.display(28)),
                      const SizedBox(height: 4),
                      Text('Умные чек-листы багажа для твоих поездок', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: cAccent, size: 36),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => NewTripScreen(store: store, onCreated: onOpenPackList)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...trips.map((t) {
              final isSelected = store.activeTrip.id == t.id;
              final pct = (t.progress * 100).toInt();

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: cSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? cAccent : cEdge,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cAccent.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cAccent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(iconForTripType(t.tripType), color: cAccent, size: 24),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: pct == 100 ? cAccent2.withValues(alpha: 0.2) : cBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$pct% собрано',
                              style: AppTheme.text(12.5, color: pct == 100 ? cAccent2 : cAccent, weight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(t.name, style: AppTheme.display(20)),
                      const SizedBox(height: 2),
                      Text('${t.destination} · ${t.days} дн. · ${t.packedItems}/${t.totalItems} вещей',
                          style: AppTheme.text(13, color: AppTheme.textMuted)),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: t.progress,
                          backgroundColor: cEdge,
                          valueColor: const AlwaysStoppedAnimation(cAccent2),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: cAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            store.selectTrip(t);
                            onOpenPackList();
                          },
                          icon: const Icon(Icons.checklist_rounded, size: 18),
                          label: Text('Открыть чек-лист', style: AppTheme.text(14, color: Colors.white, weight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Экран 2. Создание поездки
class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key, required this.store, required this.onCreated});

  final PackStore store;
  final VoidCallback onCreated;

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  final _nameController = TextEditingController(text: 'Поездка в Рим');
  final _destController = TextEditingController(text: 'Италия');
  String _selectedType = 'weekend';
  int _days = 4;

  final _types = [
    (id: 'weekend', name: 'Уикенд', icon: Icons.location_city_rounded),
    (id: 'beach', name: 'Пляж', icon: Icons.beach_access_rounded),
    (id: 'business', name: 'Бизнес', icon: Icons.business_center_rounded),
    (id: 'nature', name: 'Поход', icon: Icons.terrain_rounded),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: cInk),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Новая поездка', style: AppTheme.display(18)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Text('Конструктор багажа', style: AppTheme.display(24)),
            const SizedBox(height: 4),
            Text('Сгенерирует готовый список под формат путешествия', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: AppTheme.text(16, color: cInk),
              decoration: InputDecoration(
                labelText: 'Название поездки',
                filled: true,
                fillColor: cSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: cEdge)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _destController,
              style: AppTheme.text(16, color: cInk),
              decoration: InputDecoration(
                labelText: 'Место назначения / Город',
                filled: true,
                fillColor: cSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: cEdge)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Тип поездки', style: AppTheme.display(16)),
            const SizedBox(height: 10),
            Row(
              children: _types.map((t) {
                final isSel = _selectedType == t.id;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = t.id),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSel ? cAccent : cSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSel ? cAccent : cEdge),
                      ),
                      child: Column(
                        children: [
                          Icon(t.icon, color: isSel ? Colors.white : cInk, size: 22),
                          const SizedBox(height: 4),
                          Text(t.name, style: AppTheme.text(12, color: isSel ? Colors.white : cInk, weight: isSel ? FontWeight.w700 : FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Длительность: $_days дней', style: AppTheme.display(16)),
            Slider(
              value: _days.toDouble(),
              min: 1,
              max: 14,
              divisions: 13,
              activeColor: cAccent,
              onChanged: (v) => setState(() => _days = v.toInt()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: cAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  final n = _nameController.text.trim();
                  final d = _destController.text.trim();
                  if (n.isNotEmpty) {
                    await widget.store.createTrip(n, d.isEmpty ? 'Город' : d, _selectedType, _days);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      widget.onCreated();
                    }
                  }
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text('Сгенерировать список вещей', style: AppTheme.text(15.5, color: Colors.white, weight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран 3. Чек-лист вещей
class PackListScreen extends StatelessWidget {
  const PackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PackScope.of(context);
    final trip = store.activeTrip;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.display(24)),
                      const SizedBox(height: 2),
                      Text('${trip.destination} · ${trip.packedItems}/${trip.totalItems} собрано', style: AppTheme.text(13, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: cAccent, size: 28),
                  onPressed: () => _showAddItemDialog(context, store),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...trip.items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: cSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: item.isPacked ? cAccent2.withValues(alpha: 0.6) : cEdge),
                ),
                child: ListTile(
                  title: Text(
                    item.name,
                    style: AppTheme.text(
                      14.5,
                      color: item.isPacked ? AppTheme.textMuted : cInk,
                      weight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(item.category, style: AppTheme.text(12, color: AppTheme.textMuted)),
                  trailing: Checkbox(
                    value: item.isPacked,
                    activeColor: cAccent2,
                    checkColor: Colors.white,
                    onChanged: (_) => store.toggleItem(item),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, PackStore store) {
    final nameCtrl = TextEditingController();
    final categories = ['Документы', 'Одежда', 'Гаджеты', 'Гигиена', 'Аптечка', 'Разное'];
    String selectedCat = categories.first;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: cSurface,
          title: Text('Добавить предмет', style: AppTheme.display(18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Название вещи',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedCat,
                decoration: InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => selectedCat = v ?? selectedCat),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: cAccent),
              onPressed: () async {
                final txt = nameCtrl.text.trim();
                if (txt.isNotEmpty) {
                  await store.addItem(txt, selectedCat, 1);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран 4. Прогресс багажа
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PackScope.of(context);
    final trip = store.activeTrip;
    final remaining = trip.totalItems - trip.packedItems;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Готовность багажа', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('Сводка по сборам в поездку', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: cEdge),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: cAccent2, size: 28),
                        const SizedBox(height: 10),
                        Text('${trip.packedItems}', style: AppTheme.display(26, color: cAccent2)),
                        const SizedBox(height: 2),
                        Text('Собрано в сумку', style: AppTheme.text(12.5, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: cEdge),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.pending_actions_rounded, color: cAccent, size: 28),
                        const SizedBox(height: 10),
                        Text('$remaining', style: AppTheme.display(26, color: cAccent)),
                        const SizedBox(height: 2),
                        Text('Осталось упаковать', style: AppTheme.text(12.5, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cEdge),
              ),
              child: Row(
                children: [
                  Icon(
                    remaining == 0 ? Icons.flight_takeoff_rounded : Icons.luggage_rounded,
                    color: remaining == 0 ? cAccent2 : cAccent,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          remaining == 0 ? 'Багаж полностью готов!' : 'Сборы в процессе',
                          style: AppTheme.display(18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          remaining == 0 ? 'Все вещи по чек-листу упакованы. Приятного пути!' : 'Не забудьте проверить документы и зарядки перед выходом.',
                          style: AppTheme.text(12.5, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран 5. Настройки
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PackScope.of(context);

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Настройки', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('PackPilot v1.0.0', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cEdge),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.luggage_outlined, color: cAccent),
                    title: Text('Поездок в базе', style: AppTheme.text(15, color: cInk)),
                    trailing: Text('${store.trips.length}', style: AppTheme.text(15, color: cAccent, weight: FontWeight.w700)),
                  ),
                  const Divider(height: 1, color: cEdge),
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded, color: Colors.redAccent),
                    title: const Text('Сбросить все поездки', style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cSurface,
                          title: Text('Сбросить поездки?', style: AppTheme.display(18)),
                          content: Text('Все списки и отметки будут удалены.', style: AppTheme.text(14, color: cInk)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Отмена')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Сбросить'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await store.resetAll();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
