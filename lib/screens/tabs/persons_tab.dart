import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';
import '../../models/event.dart';

class PersonsTab extends StatelessWidget {
  final String eventId;
  const PersonsTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final Event event = provider.events.firstWhere((e) => e.id == eventId);
    return Scaffold(
      body: ListView.builder(
        itemCount: event.members.length,
        itemBuilder:
            (ctx, i) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(event.members[i].name),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMember(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Future<void> _addMember(BuildContext context) async {
    final ctrl = TextEditingController();
    final provider = context.read<EventsProvider>();
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add member'),
            content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.trim().isNotEmpty) {
                    await provider.addMember(eventId, ctrl.text.trim());
                    // ignore: use_build_context_synchronously
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
