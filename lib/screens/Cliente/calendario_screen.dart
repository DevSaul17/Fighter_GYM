import 'package:flutter/material.dart';

enum CalendarView { month, week, day }

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  CalendarView _view = CalendarView.month;
  DateTime _selected = DateTime.now();

  // Simple in-memory events map for demo purposes
  final Map<String, List<String>> _events = {};

  String _keyFor(DateTime d) => '${d.year}-${d.month}-${d.day}';

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    // Start from the first day of the week that contains the 1st (Monday)
    final start = first.subtract(Duration(days: (first.weekday + 6) % 7));
    final end = last.add(Duration(days: (7 - last.weekday) % 7));

    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  DateTime _startOfWeek(DateTime d) {
    return d.subtract(Duration(days: (d.weekday + 6) % 7));
  }

  List<DateTime> _daysInWeek(DateTime d) {
    final start = _startOfWeek(d);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  void _addSampleEvent(DateTime day) {
    final k = _keyFor(day);
    _events
        .putIfAbsent(k, () => [])
        .add('Evento de ejemplo ${_events[k]?.length ?? 0 + 1}');
    setState(() {});
  }

  Widget _buildHeader() {
    String title;
    if (_view == CalendarView.month) {
      title = '${_monthName(_selected.month)} ${_selected.year}';
    } else if (_view == CalendarView.week) {
      final start = _startOfWeek(_selected);
      final end = start.add(const Duration(days: 6));
      title = '${start.day}/${start.month} - ${end.day}/${end.month}';
    } else {
      title =
          '${_selected.day} ${_monthName(_selected.month)} ${_selected.year}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              if (_view == CalendarView.month) {
                _selected = DateTime(
                  _selected.year,
                  _selected.month - 1,
                  _selected.day,
                );
              } else if (_view == CalendarView.week) {
                _selected = _selected.subtract(const Duration(days: 7));
              } else {
                _selected = _selected.subtract(const Duration(days: 1));
              }
            });
          },
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              if (_view == CalendarView.month) {
                _selected = DateTime(
                  _selected.year,
                  _selected.month + 1,
                  _selected.day,
                );
              } else if (_view == CalendarView.week) {
                _selected = _selected.add(const Duration(days: 7));
              } else {
                _selected = _selected.add(const Duration(days: 1));
              }
            });
          },
        ),
      ],
    );
  }

  String _monthName(int m) {
    const names = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return names[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Mes'),
                  selected: _view == CalendarView.month,
                  onSelected: (_) => setState(() => _view = CalendarView.month),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Semana'),
                  selected: _view == CalendarView.week,
                  onSelected: (_) => setState(() => _view = CalendarView.week),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Día'),
                  selected: _view == CalendarView.day,
                  onSelected: (_) => setState(() => _view = CalendarView.day),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_view == CalendarView.month) _buildMonthView(),
            if (_view == CalendarView.week) _buildWeekView(),
            if (_view == CalendarView.day) _buildDayView(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView() {
    final days = _daysInMonth(_selected);
    return Expanded(
      child: Column(
        children: [
          _buildWeekDaysHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final d = days[index];
                final isToday = _isSameDay(d, DateTime.now());
                final isSelected = _isSameDay(d, _selected);
                final inMonth = d.month == _selected.month;
                final evs = _events[_keyFor(d)];

                return GestureDetector(
                  onTap: () => setState(() => _selected = d),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Text(
                            '${d.day}',
                            style: TextStyle(
                              color: inMonth ? Colors.black : Colors.black26,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (evs != null && evs.isNotEmpty)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            right: 6,
                            child: Center(
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final days = _daysInWeek(_selected);
    return Expanded(
      child: Column(
        children: [
          _buildWeekDaysHeader(),
          const SizedBox(height: 8),
          Row(
            children: days.map((d) {
              final isSelected = _isSameDay(d, _selected);
              final evs = _events[_keyFor(d)];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = d),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${d.day}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(_shortWeekDay(d.weekday)),
                        if (evs != null && evs.isNotEmpty)
                          const SizedBox(height: 6),
                        if (evs != null && evs.isNotEmpty)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildEventsList(_selected)),
        ],
      ),
    );
  }

  Widget _buildDayView() {
    return Expanded(
      child: Column(
        children: [
          _buildWeekDaysHeader(),
          const SizedBox(height: 12),
          Expanded(child: _buildEventsList(_selected)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _addSampleEvent(_selected),
            child: const Text('Añadir evento de ejemplo'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    const labels = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  String _shortWeekDay(int weekday) {
    const s = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    return s[(weekday + 6) % 7];
  }

  Widget _buildEventsList(DateTime day) {
    final evs = _events[_keyFor(day)] ?? [];
    if (evs.isEmpty) {
      return const Center(child: Text('No hay eventos'));
    }
    return ListView.separated(
      itemCount: evs.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) =>
          ListTile(title: Text(evs[i]), leading: const Icon(Icons.event)),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
