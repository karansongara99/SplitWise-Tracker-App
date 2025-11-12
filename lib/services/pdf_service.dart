import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/event.dart';
import '../screens/tabs/reports_tab.dart';

class PdfService {
  static Future<void> generateAndShareReport(
    Event event,
    List<ReportRow> rows,
    double totalExpense,
    double perHead,
  ) async {
    final doc = pw.Document();
    final dateFmt = DateFormat.yMMMd();

    doc.addPage(
      pw.Page(
        build:
            (ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Report.pdf',
                    style: pw.TextStyle(fontSize: 20),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Event: ${event.name}',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text('Date: ${dateFmt.format(event.date)}'),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Table.fromTextArray(
                  headers: ['Member', 'Income', 'Expense', 'Refund', 'Owes'],
                  data:
                      rows
                          .map(
                            (r) => [
                              r.member,
                              r.income.toStringAsFixed(2),
                              r.expense.toStringAsFixed(2),
                              r.refund.toStringAsFixed(2),
                              r.owes.toStringAsFixed(2),
                            ],
                          )
                          .toList(),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Expense Per Head: ${perHead.toStringAsFixed(2)}'),
                    pw.Text(
                      'Total Expense: ${totalExpense.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ],
            ),
      ),
    );

    final bytes = await doc.save();
    await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytes));
  }
}
