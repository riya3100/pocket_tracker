import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/app_colors.dart';
import '../screens/home/add_transaction_screen.dart';
import '../services/transaction_service.dart';

class TransactionCard extends StatelessWidget {

final QueryDocumentSnapshot<Map<String, dynamic>> transaction;

const TransactionCard({
  super.key,
  required this.transaction,
});

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "food":
        return Icons.restaurant;

      case "travel":
        return Icons.directions_car;

      case "shopping":
        return Icons.shopping_bag;

      case "salary":
        return Icons.work;

      case "health":
        return Icons.medical_services;

      case "bills":
        return Icons.receipt;

      default:
        return Icons.account_balance_wallet;
    }
  }

  Future deleteTransaction(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Transaction"),

          content: const Text(
            "Are you sure you want to delete this transaction?",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense,
              ),

              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await TransactionService().deleteTransaction(transaction.id);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction Deleted")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isIncome = transaction["type"] == "Income";

    DateTime date = (transaction["date"] as Timestamp).toDate();

    return Dismissible(
  key: Key(transaction.id),

  direction: DismissDirection.horizontal,

  background: Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(left: 20),

    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(15),
    ),

    child: const Icon(
      Icons.edit,
      color: Colors.white,
    ),
  ),


  secondaryBackground: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),

    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(15),
    ),

    child: const Icon(
      Icons.delete,
      color: Colors.white,
    ),
  ),


  confirmDismiss: (direction) async {

    // Swipe right → Edit
    if(direction == DismissDirection.startToEnd){

      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (_) => AddTransactionScreen(

            id: transaction.id,

            title: transaction["title"],

            amount:
            (transaction["amount"] as num).toDouble(),

            type: transaction["type"],

            category: transaction["category"],

            date:
            (transaction["date"] as Timestamp).toDate(),

          ),
        ),
      );

      return false;
    }


    // Swipe left → Delete
    if(direction == DismissDirection.endToStart){

      await deleteTransaction(context);

      return false;
    }


    return false;

  },


  child: Card(

    elevation: 3,

    margin: const EdgeInsets.only(bottom: 12),

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),


    child: ListTile(

      leading: CircleAvatar(

        radius: 25,

        backgroundColor: isIncome
            ? AppColors.primaryLight
            : Colors.red.shade100,


        child: Icon(
          getCategoryIcon(transaction["category"]),

          color: isIncome
              ? AppColors.primary
              : Colors.red,
        ),
      ),


      title: Text(
        transaction["title"],

        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),


      subtitle: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(transaction["category"]),


          Text(
            "${date.day}/${date.month}/${date.year}",

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

        ],
      ),


      trailing: Text(

        "${isIncome ? "+" : "-"}Rs${transaction["amount"]}",


        style: TextStyle(

          fontWeight: FontWeight.bold,

          color: isIncome
              ? AppColors.primary
              : AppColors.expense,

        ),
      ),

    ),
  ),
);
  }
}