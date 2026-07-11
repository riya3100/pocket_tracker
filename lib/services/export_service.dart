import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<void> exportPDF(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final pdf = pw.Document();

    double income = 0;
    double expense = 0;

    final rows = <List<String>>[
      [
        "Date",
        "Title",
        "Category",
        "Type",
        "Amount",
      ]
    ];

    for (final doc in docs) {
      final data = doc.data();

      final amount = (data["amount"] as num).toDouble();

      final type = data["type"];

      if (type == "Income") {
        income += amount;
      } else {
        expense += amount;
      }

      final date =
          (data["date"] as Timestamp).toDate();

      rows.add([
        "${date.day}/${date.month}/${date.year}",
        data["title"],
        data["category"],
        type,
        "Rs${amount.toStringAsFixed(2)}",
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "Pocket Tracker Report",
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Table.fromTextArray(
            data: rows,
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            "Total Income : Rs${income.toStringAsFixed(2)}",
          ),

          pw.Text(
            "Total Expense : Rs${expense.toStringAsFixed(2)}",
          ),

          pw.Text(
            "Balance : Rs${(income - expense).toStringAsFixed(2)}",
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> exportCSV(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<List<dynamic>> csvData = [];

    csvData.add([
      "Date",
      "Title",
      "Category",
      "Type",
      "Amount",
    ]);

    for (final doc in docs) {
      final data = doc.data();

      final date =
          (data["date"] as Timestamp).toDate();

      csvData.add([
        "${date.day}/${date.month}/${date.year}",
        data["title"],
        data["category"],
        data["type"],
        data["amount"],
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);

    final directory =
        await getTemporaryDirectory();

    final file = File(
      "${directory.path}/PocketTrackerReport.csv",
    );

    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Pocket Tracker Report",
    );
  }
}