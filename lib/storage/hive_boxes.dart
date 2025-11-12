import 'package:hive/hive.dart';
import '../models/member.dart';
import '../models/expense.dart';
import '../models/event.dart';

const String kEventsBox = 'events_box';

Future<void> registerHiveAdapters() async {
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MemberAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ExpenseAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(EventAdapter());
}

Future<void> openAppBoxes() async {
  if (!Hive.isBoxOpen(kEventsBox)) {
    await Hive.openBox<Event>(kEventsBox);
  }
}

Box<Event> eventsBox() => Hive.box<Event>(kEventsBox);
