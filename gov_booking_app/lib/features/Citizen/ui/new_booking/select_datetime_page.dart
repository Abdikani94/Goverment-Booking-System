import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectDateTimePage extends StatefulWidget {
  final String officeId;
  final String serviceId;
  final String serviceName;

  const SelectDateTimePage({
    super.key,
    required this.officeId,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<SelectDateTimePage> createState() => _SelectDateTimePageState();
}

class _SelectDateTimePageState extends State<SelectDateTimePage> {
  DateTime selectedDate = DateTime.now();
  String selectedPeriod = "Morning";
  String selected = "9:30 AM";

  static const List<String> _morning = [
    "9:00 AM",
    "9:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
  ];

  static const List<String> _afternoon = [
    "1:00 PM",
    "1:30 PM",
    "2:00 PM",
    "2:30 PM",
    "3:00 PM",
    "3:30 PM",
  ];

  @override
  Widget build(BuildContext context) {
    final firstMonth = DateTime(selectedDate.year, selectedDate.month);
    final secondMonth = DateTime(selectedDate.year, selectedDate.month + 1);
    final slots = selectedPeriod == "Morning" ? _morning : _afternoon;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, color: Color(0xFF111827)),
        ),
        title: const Text(
          "Select Date & Time",
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
        children: [
          _MonthView(
            month: firstMonth,
            selectedDate: selectedDate,
            showPreviousIcon: true,
            onTapDay: (day) => setState(() => selectedDate = day),
          ),
          const SizedBox(height: 14),
          _MonthView(
            month: secondMonth,
            selectedDate: selectedDate,
            showNextIcon: true,
            onTapDay: (day) => setState(() => selectedDate = day),
          ),
          const SizedBox(height: 18),
          const Text(
            "Select Time",
            style: TextStyle(
              fontSize: 32,
              height: 1.0,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _PeriodTab(
                label: "Morning",
                selected: selectedPeriod == "Morning",
                onTap: () => setState(() {
                  selectedPeriod = "Morning";
                  selected = _morning.first;
                }),
              ),
              const SizedBox(width: 8),
              _PeriodTab(
                label: "Afternoon",
                selected: selectedPeriod == "Afternoon",
                onTap: () => setState(() {
                  selectedPeriod = "Afternoon";
                  selected = _afternoon.first;
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slots.map((t) {
              final isSelected = t == selected;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => selected = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEAF0FF) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2456D6) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        size: 16,
                        color: isSelected ? const Color(0xFF2456D6) : const Color(0xFF111827),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2456D6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                context.go(
                  '/citizen/book/review'
                  '?officeId=${widget.officeId}'
                  '&serviceId=${widget.serviceId}'
                  '&slot=${Uri.encodeComponent(selected)}',
                );
              },
              child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.month,
    required this.selectedDate,
    required this.onTapDay,
    this.showPreviousIcon = false,
    this.showNextIcon = false,
  });

  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onTapDay;
  final bool showPreviousIcon;
  final bool showNextIcon;

  static const List<String> _week = ["S", "M", "T", "W", "T", "F", "S"];

  @override
  Widget build(BuildContext context) {
    final year = month.year;
    final m = month.month;
    final first = DateTime(year, m, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, m);
    final leadingBlanks = first.weekday % 7;

    final cells = <Widget>[];
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, m, day);
      final isSelected = DateUtils.isSameDay(selectedDate, date);
      cells.add(
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onTapDay(date),
          child: Container(
            alignment: Alignment.center,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2456D6) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              "$day",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: showPreviousIcon ? const Icon(Icons.chevron_left, size: 18) : null,
              ),
              Expanded(
                child: Text(
                  _monthLabel(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                ),
              ),
              SizedBox(
                width: 24,
                child: showNextIcon ? const Icon(Icons.chevron_right, size: 18) : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _week
                .map((w) => SizedBox(
                      width: 34,
                      child: Center(
                        child: Text(
                          w,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            children: cells,
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const names = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${names[d.month - 1]} ${d.year}";
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF0FF) : const Color(0xFFEDEFF3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: selected ? const Color(0xFF2456D6) : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}
