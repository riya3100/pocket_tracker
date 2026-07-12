import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/transaction_service.dart';
import '../../services/export_service.dart';
import '../../utils/app_colors.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final TransactionService transactionService = TransactionService();
  final ExportService exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: transactionService.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Statistics"),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text("No Transactions Found"),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        double income = 0;
        double expense = 0;

        Map<String, double> categoryTotals = {};

        for (var doc in docs) {
          final data = doc.data();

          double amount = (data["amount"] as num).toDouble();

          String type = data["type"];

          String category = data["category"];

          if (type == "Income") {
            income += amount;
          } else {
            expense += amount;

            categoryTotals[category] =
                (categoryTotals[category] ?? 0) + amount;
          }
        }

        double balance = income - expense;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

          appBar: AppBar(
            title: const Text("Statistics"),
           backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
foregroundColor: Theme.of(context).appBarTheme.foregroundColor,

            actions: [
              IconButton(
                icon: const Icon(Icons.download),

                onPressed: () {
                  showModalBottomSheet(
                    context: context,

                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            ListTile(
                              leading:
                                  const Icon(Icons.picture_as_pdf),

                              title: const Text("Export PDF"),

                              onTap: () async {
                                Navigator.pop(context);

                                await exportService.exportPDF(docs);
                              },
                            ),

                            ListTile(
                              leading:
                                  const Icon(Icons.table_chart),

                              title: const Text("Export CSV"),

                              onTap: () async {
                                Navigator.pop(context);

                                await exportService.exportCSV(docs);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),

          body: ListView(
            padding: const EdgeInsets.all(20),

            children: [

             Card(
  elevation: 5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: Theme.of(context).dividerColor,
      width: 1,
    ),
  ),


                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,

                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                    ),
                  ),

                  title: const Text("Current Balance"),

                  trailing: Text(
                    "₹${balance.toStringAsFixed(2)}",

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),

                        child: Column(
                          children: [

                            const Icon(
                              Icons.arrow_downward,
                              color: AppColors.primary,
                              size: 30,
                            ),

                            const SizedBox(height: 10),

                            const Text("Income"),

                            const SizedBox(height: 5),

                            Text(
                              "₹${income.toStringAsFixed(2)}",

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),

                        child: Column(
                          children: [

                            const Icon(
                              Icons.arrow_upward,
                              color: AppColors.expense,
                              size: 30,
                            ),

                            const SizedBox(height: 10),

                            const Text("Expense"),

                            const SizedBox(height: 5),

                            Text(
                              "₹${expense.toStringAsFixed(2)}",

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

Divider(
  thickness: 1.2,
  color: Theme.of(context).dividerColor,
),

const SizedBox(height: 24),
              if (income > 0 || expense > 0)
                SizedBox(
                  height: 250,

                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 55,

                      sectionsSpace: 3,

                      sections: [

                        PieChartSectionData(
                          value: income,
                          color: AppColors.primary,
                          radius: 70,
                          title: "Income",
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        PieChartSectionData(
                          value: expense,
                          color: AppColors.expense,
                          radius: 70,
                          title: "Expense",
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

Divider(
  thickness: 1.2,
  color: Theme.of(context).dividerColor,
),

const SizedBox(height: 24),

              const Text(
                "Expenses by Category",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),
                            if (categoryTotals.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      "No Expense Data",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

              ...categoryTotals.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),

                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,

                      child: Icon(
                        Icons.pie_chart,
                        color: AppColors.primary,
                      ),
                    ),

                    title: Text(entry.key),

                    subtitle: LinearProgressIndicator(
                      value: expense == 0
                          ? 0
                          : entry.value / expense,
                     backgroundColor: Theme.of(context).dividerColor,
                      color: AppColors.primary,
                    ),

                    trailing: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      "₹${entry.value.toStringAsFixed(2)}",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      "${((entry.value / expense) * 100).toStringAsFixed(1)}%",
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
  ],
),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}