import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_transaction_screen.dart';
import '../../services/transaction_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
  
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalIncome = 0;
  double totalExpense = 0;
final TransactionService transactionService = TransactionService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

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

          // RESET VALUES
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

              const Text(
                "Good Afternoon 👋",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 5),

              const Text(
                "Riya",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              // BALANCE CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
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

              // INCOME + EXPENSE
              Row(
                children: [

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Icon(Icons.arrow_downward,
                                color: Colors.green.shade600),
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
                            const Icon(Icons.arrow_upward, color: Colors.red),
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

              const SizedBox(height: 30),

              const Text(
                "Recent Transactions",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              // TRANSACTIONS LIST
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
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          transaction["type"] == "Income"
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: transaction["type"] == "Income"
                              ? Colors.green
                              : Colors.red,
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
            ? Colors.green
            : Colors.red,
      ),
    ),

    IconButton(
      icon: const Icon(
        Icons.edit,
        color: Colors.blue,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(
              id: transaction.id,
              title: transaction["title"],
              amount: (transaction["amount"] as num).toDouble(),
              type: transaction["type"],
              category: transaction["category"],
              date: (transaction["date"] as Timestamp).toDate(),
            ),
          ),
        );
      },
    ),

    IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () async {
        bool? confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Transaction"),
            content: const Text(
              "Are you sure you want to delete this transaction?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Delete"),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await transactionService.deleteTransaction(transaction.id);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Transaction Deleted"),
            ),
          );
        }
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
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}