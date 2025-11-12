import 'package:flutter/material.dart';
import '../../providers/events_provider.dart';
import 'persons_tab.dart';
import 'transactions_tab.dart';
import 'reports_tab.dart';
import 'package:provider/provider.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventsProvider>();
    final event = events.events.firstWhere((e) => e.id == eventId);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(event.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Person'),
              Tab(text: 'Transactions'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PersonsTab(eventId: eventId),
            TransactionsTab(eventId: eventId),
            ReportsTab(eventId: eventId),
          ],
        ),
      ),
    );
  }
}
