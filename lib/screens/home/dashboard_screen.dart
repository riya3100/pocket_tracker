import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_transaction_screen.dart';
import '../../services/transaction_service.dart';
import '../../services/budget_service.dart';
import '../../widgets/budget_card.dart';
import '../../models/budget_model.dart';
import '../../utils/app_colors.dart';
import '../budget/set_budget_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalIncome = 0;
  double totalExpense = 0;

  final TransactionService transactionService = TransactionService();

  final User? user = FirebaseAuth.instance.currentUser;

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning ☀️";
    } else if (hour < 17) {
      return "Good Afternoon 🌤️";
    } else {
      return "Good Evening 🌙";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,

        title: Row(
          children: [
            Image.asset(
              "assets/images/pocket_tracker_logo.png",
              width: 40,
              height: 40,
            ),

            const SizedBox(width: 10),

            const Text(
              "Pocket Tracker",

              style: TextStyle(
                color: Colors.black,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("transactions")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          totalIncome = 0;
          totalExpense = 0;

          for (var doc in docs) {
            double amount = (doc["amount"] as num).toDouble();

            if (doc["type"] == "Income") {
              totalIncome += amount;
            } else {
              totalExpense += amount;
            }
          }

          double totalBalance = totalIncome - totalExpense;

          return ListView(
            padding: const EdgeInsets.all(20),

            children: [
              Text(
                getGreeting(),

                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 5),

              Text(
                user?.email?.split("@")[0] ?? "User",

                style: const TextStyle(
                  fontSize: 30,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // BALANCE CARD
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: AppColors.primary,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Total Balance",

                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "₹${totalBalance.toStringAsFixed(2)}",

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 32,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // INCOME EXPENSE
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
                            ),

                            const SizedBox(height: 8),

                            const Text("Income"),

                            Text("₹${totalIncome.toStringAsFixed(2)}"),
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
                            ),

                            const SizedBox(height: 8),

                            const Text("Expense"),

                            Text("₹${totalExpense.toStringAsFixed(2)}"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // BUDGET CARD
              StreamBuilder<BudgetModel?>(
                stream: BudgetService().getBudget(
                  FirebaseAuth.instance.currentUser!.uid,
                ),

                builder: (context, budgetSnapshot) {
                  if (!budgetSnapshot.hasData ||
    budgetSnapshot.data == null) {

  return Card(

    elevation: 3,

    child: ListTile(

      leading: const CircleAvatar(

        backgroundColor:
            AppColors.primaryLight,

        child: Icon(
          Icons.account_balance_wallet,
          color: AppColors.primary,
        ),

      ),



      title: const Text(

        "No Budget Found",

        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),

      ),



      subtitle: const Text(
        "Create your monthly budget",
      ),



      trailing: ElevatedButton(

        style: ElevatedButton.styleFrom(

          backgroundColor:
              AppColors.primary,

        ),


        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const SetBudgetScreen(),

            ),

          );

        },


        child: const Text(

          "Create",

          style: TextStyle(
            color: Colors.white,
          ),

        ),

      ),

    ),

  );

}

                  return BudgetCard(
                    budget: budgetSnapshot.data!,

                    spent: totalExpense,
                  );
                },
              ),

              const SizedBox(height: 30),

              const Text(
                "Recent Transactions",

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              ListView.builder(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: docs.length,

                itemBuilder: (context, index) {
                  var transaction = docs[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),

                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: transaction["type"] == "Income"
                            ? AppColors.primaryLight
                            : AppColors.expense,

                        child: Icon(
                          transaction["type"] == "Income"
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,

                          color: transaction["type"] == "Income"
                              ? AppColors.primary
                              : AppColors.expense,
                        ),
                      ),

                      title: Text(transaction["title"]),

                      subtitle: Text(transaction["category"]),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Text(
                            "₹${transaction["amount"]}",

                            style: TextStyle(
                              fontWeight: FontWeight.bold,

                              color: transaction["type"] == "Income"
                                  ? AppColors.primary
                                  : AppColors.expense,
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),

                            onPressed: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) => AddTransactionScreen(
                                    id: transaction.id,

                                    title: transaction["title"],

                                    amount: (transaction["amount"] as num)
                                        .toDouble(),

                                    type: transaction["type"],

                                    category: transaction["category"],

                                    date: (transaction["date"] as Timestamp)
                                        .toDate(),
                                  ),
                                ),
                              );
                            },
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete,

                              color: AppColors.expense,
                            ),

                            onPressed: () async {
                              await transactionService.deleteTransaction(
                                transaction.id,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Transaction Deleted"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,

        onPressed: () {
          Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
