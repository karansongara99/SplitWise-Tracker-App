import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/events_provider.dart';
import 'tabs/event_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: ListView.builder(
        itemCount: provider.events.length,
        itemBuilder: (ctx, i) {
          final e = provider.events[i];
          final total = provider.totalExpense(e.id);
          return ListTile(
            title: Text(e.name),
            subtitle: Text(DateFormat.yMMMd().format(e.date)),
            trailing: Text(total.toStringAsFixed(2)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(eventId: e.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showAddEventDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    DateTime date = DateTime.now();
    final provider = context.read<EventsProvider>();
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('New Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Event name'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(DateFormat.yMMMd().format(date)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime(2010),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          date = picked;
                          // rebuild small
                          (ctx as Element).markNeedsBuild();
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    await provider.addEvent(nameCtrl.text.trim(), date);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }
}
