import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/events_provider.dart';
import 'screens/home_screen.dart';
import 'storage/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await registerHiveAdapters();
  await openAppBoxes();
  runApp(const SplitWiseTrackerApp());
}

class SplitWiseTrackerApp extends StatelessWidget {
  const SplitWiseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventsProvider()..load()),
      ],
      child: MaterialApp(
        title: 'Splitwise Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
