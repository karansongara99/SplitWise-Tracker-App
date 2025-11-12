import 'package:hive/hive.dart';
import 'member.dart';
import 'expense.dart';

@HiveType(typeId: 3)
class Event {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  List<Member> members;
  @HiveField(4)
  List<Expense> expenses;

  Event({
    required this.id,
    required this.name,
    required this.date,
    List<Member>? members,
    List<Expense>? expenses,
  }) : members = members ?? [],
       expenses = expenses ?? [];

  double totalExpense() => expenses.fold(0.0, (sum, e) => sum + e.amount);
}

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 3;

  @override
  Event read(BinaryReader reader) {
    final m = reader.readMap().cast<int, dynamic>();
    return Event(
      id: m[0] as String,
      name: m[1] as String,
      date: DateTime.parse(m[2] as String),
      members: (m[3] as List).cast<Member>(),
      expenses: (m[4] as List).cast<Expense>(),
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer.writeMap({
      0: obj.id,
      1: obj.name,
      2: obj.date.toIso8601String(),
      3: obj.members,
      4: obj.expenses,
    });
  }
}
