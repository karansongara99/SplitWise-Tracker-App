import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';
import '../../models/event.dart';

class TransactionsTab extends StatelessWidget {
  final String eventId;
  const TransactionsTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final Event event = provider.events.firstWhere((e) => e.id == eventId);
    return Scaffold(
      body: ListView.builder(
        itemCount: event.expenses.length,
        itemBuilder: (ctx, i) {
          final ex = event.expenses[i];
          final payerName =
              event.members.firstWhere((m) => m.id == ex.paidByMemberId).name;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(ex.title),
              subtitle: Text(
                '${DateFormat.yMMMd().format(ex.date)} • Paid by $payerName',
              ),
              trailing: Text(ex.amount.toStringAsFixed(2)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addExpense(context, event),
        child: const Icon(Icons.add_card),
      ),
    );
  }

  Future<void> _addExpense(BuildContext context, Event event) async {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    double amount = 0;
    DateTime date = DateTime.now();
    String? payerId = event.members.isNotEmpty ? event.members.first.id : null;
    final selected = <String>{...event.members.map((m) => m.id)};

    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setS) => AlertDialog(
                  title: const Text('Add expense'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => amount = double.tryParse(v) ?? 0,
                        ),
                        Row(
                          children: [
                            Text(DateFormat.yMMMd().format(date)),
                            const Spacer(),
                            TextButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: ctx,
                                  initialDate: date,
                                  firstDate: DateTime(2010),
                                  lastDate: DateTime(2100),
                                );
                                if (d != null) setS(() => date = d);
                              },
                              child: const Text('Pick date'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: payerId,
                          items:
                              event.members
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m.id,
                                      child: Text('Paid by ${m.name}'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setS(() => payerId = v),
                          decoration: const InputDecoration(labelText: 'Payer'),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text('Split among'),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final m in event.members)
                              FilterChip(
                                label: Text(m.name),
                                selected: selected.contains(m.id),
                                onSelected:
                                    (sel) => setS(() {
                                      if (sel) {
                                        selected.add(m.id);
                                      } else {
                                        selected.remove(m.id);
                                      }
                                    }),
                              ),
                          ],
                        ),
                        TextField(
                          controller: noteCtrl,
                          decoration: const InputDecoration(labelText: 'Note'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if ((titleCtrl.text.trim().isEmpty) ||
                            payerId == null ||
                            amount <= 0)
                          return;
                        await context.read<EventsProvider>().addExpense(
                          eventId: event.id,
                          title: titleCtrl.text.trim(),
                          amount: amount,
                          date: date,
                          paidByMemberId: payerId!,
                          splitAmongMemberIds: selected.toList(),
                          note:
                              noteCtrl.text.trim().isEmpty
                                  ? null
                                  : noteCtrl.text.trim(),
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }
}
