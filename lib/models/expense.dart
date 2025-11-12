import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Expense {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  double amount;
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  String paidByMemberId;
  @HiveField(5)
  List<String> splitAmongMemberIds;
  @HiveField(6)
  String? note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.paidByMemberId,
    required this.splitAmongMemberIds,
    this.note,
  });
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;

  @override
  Expense read(BinaryReader reader) {
    final m = reader.readMap().cast<int, dynamic>();
    return Expense(
      id: m[0] as String,
      title: m[1] as String,
      amount: (m[2] as num).toDouble(),
      date: DateTime.parse(m[3] as String),
      paidByMemberId: m[4] as String,
      splitAmongMemberIds: (m[5] as List).cast<String>(),
      note: m[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeMap({
      0: obj.id,
      1: obj.title,
      2: obj.amount,
      3: obj.date.toIso8601String(),
      4: obj.paidByMemberId,
      5: obj.splitAmongMemberIds,
      6: obj.note,
    });
  }
}