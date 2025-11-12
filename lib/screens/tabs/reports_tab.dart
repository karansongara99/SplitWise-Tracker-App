import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';
import '../../models/event.dart';
import '../../services/pdf_service.dart';

class ReportsTab extends StatelessWidget {
  final String eventId;
  const ReportsTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final Event event = provider.events.firstWhere((e) => e.id == eventId);

    final paid = provider.paidTotals(eventId);
    final share = provider.shareTotals(eventId);
    final rows =
        event.members.map((m) {
          final double income = paid[m.id] ?? 0.0;
          final double expense = share[m.id] ?? 0.0;
          final double owes = (expense - income);
          return ReportRow(m.name, income, expense, 0.0, owes);
        }).toList();

    final totalExpense = provider.totalExpense(eventId);
    final double perHead =
        event.members.isEmpty ? 0.0 : totalExpense / event.members.length;

    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Text('Event: ${event.name}'),
            subtitle: Text('Date: ${DateFormat.yMMMd().format(event.date)}'),
            trailing: Text('Total: ${totalExpense.toStringAsFixed(2)}'),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Member')),
                  DataColumn(label: Text('Income')),
                  DataColumn(label: Text('Expense')),
                  DataColumn(label: Text('Refund')),
                  DataColumn(label: Text('Owes')),
                ],
                rows:
                    rows
                        .map(
                          (r) => DataRow(
                            cells: [
                              DataCell(Text(r.member)),
                              DataCell(Text(r.income.toStringAsFixed(2))),
                              DataCell(Text(r.expense.toStringAsFixed(2))),
                              const DataCell(Text('0.00')),
                              DataCell(Text(r.owes.toStringAsFixed(2))),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text('Expense Per Head: ${perHead.toStringAsFixed(2)}'),
                const Spacer(),
                Text('Total Expense: ${totalExpense.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => PdfService.generateAndShareReport(
              event,
              rows,
              totalExpense,
              perHead,
            ),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('PDF'),
      ),
    );
  }
}

class ReportRow {
  final String member;
  final double income;
  final double expense;
  final double refund;
  final double owes;
  ReportRow(this.member, this.income, this.expense, this.refund, this.owes);
}
