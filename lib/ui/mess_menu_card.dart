import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/ui/app_theme.dart';

/// ---------------------------------------------------------------------
/// DATA MODEL — maps to messMenu/{day} docs, e.g.:
/// messMenu/monday { breakfast: {time, items[]}, lunch: {...}, ... }
/// ---------------------------------------------------------------------
class MealInfo {
  final String time;
  final List<String> items;

  const MealInfo({required this.time, required this.items});

  factory MealInfo.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const MealInfo(time: '', items: []);
    return MealInfo(
      time: map['time'] as String? ?? '',
      items: List<String>.from(map['items'] as List? ?? []),
    );
  }
}

class DayMenu {
  final Map<String, MealInfo> meals; // keys: breakfast, lunch, snacks, dinner

  const DayMenu({required this.meals});

  factory DayMenu.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DayMenu(
      meals: {
        for (final mealType in mealTypes)
          mealType: MealInfo.fromMap(data[mealType] as Map<String, dynamic>?),
      },
    );
  }
}

const List<String> mealTypes = ['breakfast', 'lunch', 'snacks', 'dinner'];
const List<String> _weekdayDocIds = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

String _dayLabel(String dayId) {
  final short = dayId.substring(0, 3);
  return '${short[0].toUpperCase()}${short.substring(1)}';
}

String _mealLabel(String mealType) =>
    '${mealType[0].toUpperCase()}${mealType.substring(1)}';

/// ---------------------------------------------------------------------
/// WIDGET
/// ---------------------------------------------------------------------
class MessMenuCard extends StatefulWidget {
  const MessMenuCard({super.key});

  @override
  State<MessMenuCard> createState() => _MessMenuCardState();
}

class _MessMenuCardState extends State<MessMenuCard> {
  late String _selectedDay;
  String _selectedMeal = 'breakfast';

  @override
  void initState() {
    super.initState();
    // Default to today. DateTime.weekday is 1 (Mon) .. 7 (Sun).
    _selectedDay = _weekdayDocIds[DateTime.now().weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('messMenu')
          .doc(_selectedDay)
          .snapshots(),
      builder: (context, snap) {
        final dayMenu = snap.hasData ? DayMenu.fromDoc(snap.data!) : null;
        final meal = dayMenu?.meals[_selectedMeal];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mess Menu', style: AppTextStyles.h1),
                _DayDropdown(
                  selectedDay: _selectedDay,
                  onChanged: (day) => setState(() => _selectedDay = day),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MealTypeColumn(
                    selectedMeal: _selectedMeal,
                    onSelected: (meal) => setState(() => _selectedMeal = meal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MenuCard(meal: meal, isLoading: !snap.hasData),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DayDropdown extends StatelessWidget {
  final String selectedDay;
  final ValueChanged<String> onChanged;

  const _DayDropdown({required this.selectedDay, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => [
        for (final day in _weekdayDocIds)
          PopupMenuItem(value: day, child: Text(_dayLabel(day))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_dayLabel(selectedDay), style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MealTypeColumn extends StatelessWidget {
  final String selectedMeal;
  final ValueChanged<String> onSelected;

  const _MealTypeColumn({required this.selectedMeal, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        children: [
          for (final mealType in mealTypes) ...[
            _MealChip(
              label: _mealLabel(mealType),
              isSelected: mealType == selectedMeal,
              onTap: () => onSelected(mealType),
            ),
            if (mealType != mealTypes.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MealChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: const Color(0xFF3D5AFE), width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isSelected ? const Color(0xFF3D5AFE) : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MealInfo? meal;
  final bool isLoading;

  const _MenuCard({required this.meal, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final hasItems = meal != null && meal!.items.isNotEmpty;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF3D5AFE),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasItems
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in meal!.items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                        ],
                      ),
                    )
                  : const Text(
                      'No menu uploaded',
                      style: TextStyle(fontSize: 16, color: Color(0xFF1F3A5F)),
                    ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: const Color(0xFF3D5AFE),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal != null && meal!.time.isNotEmpty ? meal!.time : '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // TODO: replace with whatever this icon actually links
                // to (live announcement? mess helpline?) — placeholder.
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.podcasts,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
