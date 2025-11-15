import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/event.dart';
import '../models/member.dart';
import '../models/expense.dart';
import '../storage/hive_boxes.dart';

class EventsProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  late Box<Event> _box;
  List<Event> _events = [];

  List<Event> get events => _events;

  Future<void> load() async {
    _box = eventsBox();
    _events = _box.values.toList(growable: true);
    notifyListeners();
  }

  Future<void> addEvent(String name, DateTime date) async {
    final e = Event(id: _uuid.v4(), name: name, date: date);
    await _box.put(e.id, e);
    _events.add(e);
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    await _box.delete(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Event? byId(String id) =>
      _events.firstWhere((e) => e.id == id, orElse: () => null as Event);

  Future<void> addMember(String eventId, String name) async {
    final ev = _box.get(eventId);
    if (ev == null) return;
    ev.members.add(Member(id: _uuid.v4(), name: name));
    await _box.put(ev.id, ev);
    await load();
  }

  Future<void> updateMemberName(
    String eventId,
    String memberId,
    String newName,
  ) async {
    final ev = _box.get(eventId);
    if (ev == null) return;
    final idx = ev.members.indexWhere((m) => m.id == memberId);
    if (idx == -1) return;
    ev.members[idx].name = newName;
    await _box.put(ev.id, ev);
    await load();
  }

  Future<void> deleteMember(String eventId, String memberId) async {
    final ev = _box.get(eventId);
    if (ev == null) return;
    ev.members.removeWhere((m) => m.id == memberId);
    await _box.put(ev.id, ev);
    await load();
  }

  Future<void> addExpense({
    required String eventId,
    required String title,
    required double amount,
    required DateTime date,
    required String paidByMemberId,
    required List<String> splitAmongMemberIds,
    String? note,
  }) async {
    final ev = _box.get(eventId);
    if (ev == null) return;
    ev.expenses.add(
      Expense(
        id: _uuid.v4(),
        title: title,
        amount: amount,
        date: date,
        paidByMemberId: paidByMemberId,
        splitAmongMemberIds: splitAmongMemberIds,
        note: note,
      ),
    );
    await _box.put(ev.id, ev);
    await load();
  }

  // Reporting helpers
  double totalExpense(String eventId) {
    final ev = _box.get(eventId);
    if (ev == null) return 0;
    return ev.totalExpense();
  }

  Map<String, double> paidTotals(String eventId) {
    final ev = _box.get(eventId);
    if (ev == null) return {};
    final map = <String, double>{};
    for (final m in ev.members) {
      map[m.id] = 0;
    }
    for (final ex in ev.expenses) {
      map[ex.paidByMemberId] = (map[ex.paidByMemberId] ?? 0) + ex.amount;
    }
    return map;
  }

  Map<String, double> shareTotals(String eventId) {
    final ev = _box.get(eventId);
    if (ev == null) return {};
    final map = <String, double>{};
    for (final m in ev.members) {
      map[m.id] = 0;
    }
    for (final ex in ev.expenses) {
      final share =
          ex.amount /
          (ex.splitAmongMemberIds.isEmpty
              ? ev.members.length
              : ex.splitAmongMemberIds.length);
      final ids =
          ex.splitAmongMemberIds.isEmpty
              ? ev.members.map((m) => m.id)
              : ex.splitAmongMemberIds;
      for (final id in ids) {
        map[id] = (map[id] ?? 0) + share;
      }
    }
    return map;
  }
}
