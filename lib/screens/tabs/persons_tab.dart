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
      body:
          event.members.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          size: 44,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No members',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Add people to split expenses',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: event.members.length,
                itemBuilder: (ctx, i) {
                  final m = event.members[i];
                  final initials =
                      m.name.trim().isEmpty
                          ? '?'
                          : m.name
                              .trim()
                              .split(RegExp(r"\s+"))
                              .map((s) => s[0].toUpperCase())
                              .take(2)
                              .join();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      elevation: 1.5,
                      shadowColor: Colors.black.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                          child: Text(
                            initials,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        trailing: PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onSelected: (v) async {
                            if (v == 'edit') {
                              await _editMember(context, m.id, m.name);
                            } else if (v == 'delete') {
                              await _confirmDelete(context, m.id, m.name);
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit_outlined),
                                    title: Text('Edit'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete_outline),
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMember(context),
        tooltip: 'Add member',
        elevation: 3,
        child: const Icon(Icons.person_add_alt_1_rounded),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            title: const Text(
              'Add member',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Theme.of(
                    ctx,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(ctx).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
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
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _editMember(
    BuildContext context,
    String memberId,
    String currentName,
  ) async {
    final ctrl = TextEditingController(text: currentName);
    final provider = context.read<EventsProvider>();
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            title: const Text(
              'Edit member',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Theme.of(
                    ctx,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(ctx).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = ctrl.text.trim();
                  if (name.isNotEmpty) {
                    await provider.updateMemberName(eventId, memberId, name);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String memberId,
    String name,
  ) async {
    final provider = context.read<EventsProvider>();
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            title: const Text(
              'Remove member',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Remove \"$name\" from this event? This won\'t delete past expenses.',
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton.tonal(
                onPressed: () async {
                  await provider.deleteMember(eventId, memberId);
                  Navigator.pop(ctx);
                },
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }
}
