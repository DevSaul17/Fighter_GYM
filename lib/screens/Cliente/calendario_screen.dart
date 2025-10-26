import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

enum CalendarView { month, week, day }

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  CalendarView _view = CalendarView.month;
  DateTime _selected = DateTime.now();

  // Events loaded from the local database. Key: 'YYYY-MM-DD'
  final Map<String, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    // load events for the current visible month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventsForMonth(_selected);
    });
  }

  String _keyFor(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadEventsForMonth(DateTime month) async {
    // compute start and end of month view (covers full weeks shown)
    final days = _daysInMonth(month);
    if (days.isEmpty) return;
    final start = days.first;
    final end = days.last;
    final res = await DatabaseHelper.instance.getEventosBetween(
      _isoDate(start),
      _isoDate(end),
    );

    // clear existing entries for that range
    setState(() {
      // remove keys in the range
      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        _events.remove(_keyFor(d));
      }

      for (final r in res) {
        final fecha = r['fecha'] as String? ?? '';
        // fecha expected as 'YYYY-MM-DD'
        final key = fecha;
        _events.putIfAbsent(key, () => []).add(r);
      }
    });
  }

  Future<void> _loadEventsForDay(DateTime day) async {
    final key = _keyFor(day);
    final res = await DatabaseHelper.instance.getEventosBetween(key, key);
    setState(() {
      _events[key] = res;
    });
  }

  Future<void> _loadEventsForWeek(DateTime day) async {
    final start = _startOfWeek(day);
    final end = start.add(const Duration(days: 6));
    final res = await DatabaseHelper.instance.getEventosBetween(
      _isoDate(start),
      _isoDate(end),
    );
    setState(() {
      // clear existing keys in that week
      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        _events.remove(_keyFor(d));
      }
      for (final r in res) {
        final fecha = r['fecha'] as String? ?? '';
        _events.putIfAbsent(fecha, () => []).add(r);
      }
    });
  }

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

  // legacy helper removed; use the Add dialog instead

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
    return DefaultTabController(
      length: 3,
      initialIndex: _view == CalendarView.month
          ? 0
          : _view == CalendarView.week
          ? 1
          : 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Calendario'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TabBar(
                onTap: (i) {
                  setState(() {
                    _view = i == 0
                        ? CalendarView.month
                        : i == 1
                        ? CalendarView.week
                        : CalendarView.day;
                  });
                  // load events appropriate for selected view
                  if (i == 0) {
                    _loadEventsForMonth(_selected);
                  } else if (i == 1) {
                    _loadEventsForWeek(_selected);
                  } else {
                    _loadEventsForDay(_selected);
                  }
                },
                indicator: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.blue.shade800,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Mes'),
                  Tab(text: 'Semana'),
                  Tab(text: 'Día'),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Header with chevrons and period title
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
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
                              _selected = _selected.subtract(
                                const Duration(days: 7),
                              );
                            } else {
                              _selected = _selected.subtract(
                                const Duration(days: 1),
                              );
                            }
                          });
                          // reload events for new visible range
                          if (_view == CalendarView.month) {
                            _loadEventsForMonth(_selected);
                          } else if (_view == CalendarView.week) {
                            _loadEventsForWeek(_selected);
                          } else {
                            _loadEventsForDay(_selected);
                          }
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _headerTitle(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                              _selected = _selected.add(
                                const Duration(days: 7),
                              );
                            } else {
                              _selected = _selected.add(
                                const Duration(days: 1),
                              );
                            }
                          });
                          // reload events for new visible range
                          if (_view == CalendarView.month) {
                            _loadEventsForMonth(_selected);
                          } else if (_view == CalendarView.week) {
                            _loadEventsForWeek(_selected);
                          } else {
                            _loadEventsForDay(_selected);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMonthView(),
                        _buildWeekView(),
                        _buildDayView(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _headerTitle() {
    if (_view == CalendarView.month) {
      return '${_monthName(_selected.month)} ${_selected.year}';
    } else if (_view == CalendarView.week) {
      final start = _startOfWeek(_selected);
      final end = start.add(const Duration(days: 6));
      return '${start.day}/${start.month} - ${end.day}/${end.month}';
    } else {
      return '${_selected.day} ${_monthName(_selected.month)} ${_selected.year}';
    }
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
                  onTap: () {
                    setState(() => _selected = d);
                    _loadEventsForDay(d);
                  },
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
            onPressed: () => _openAddEventDialog(_selected),
            child: const Text('Añadir evento'),
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
      itemBuilder: (context, i) {
        final e = evs[i];
        final titulo = e['titulo'] as String? ?? '';
        final desc = e['descripcion'] as String? ?? '';
        final id = e['id'] as int?;
        return ListTile(
          leading: const Icon(Icons.event),
          title: Text(titulo),
          subtitle: desc.isNotEmpty ? Text(desc) : null,
          trailing: IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: id == null
                ? null
                : () async {
                    await DatabaseHelper.instance.deleteEvento(id);
                    await _loadEventsForDay(day);
                  },
          ),
        );
      },
    );
  }

  Future<void> _openAddEventDialog(DateTime day) async {
    final tituloC = TextEditingController();
    final descC = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir evento'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: tituloC,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingrese título' : null,
              ),
              TextFormField(
                controller: descC,
                decoration: const InputDecoration(labelText: 'Descripción'),
                minLines: 1,
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final navigator = Navigator.of(ctx);
                await DatabaseHelper.instance.insertEvento({
                  'titulo': tituloC.text.trim(),
                  'descripcion': descC.text.trim(),
                  'fecha': _isoDate(day),
                });
                if (!mounted) return;
                navigator.pop(true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _loadEventsForDay(day);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
