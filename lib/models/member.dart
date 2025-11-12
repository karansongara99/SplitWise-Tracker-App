import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Member {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;

  Member({required this.id, required this.name});
}

// Manual adapter
class MemberAdapter extends TypeAdapter<Member> {
  @override
  final int typeId = 1;

  @override
  Member read(BinaryReader reader) {
    final fields = reader.readMap().cast<int, dynamic>();
    return Member(id: fields[0] as String, name: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, Member obj) {
    writer.writeMap({0: obj.id, 1: obj.name});
  }
}
