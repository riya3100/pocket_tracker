import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? id;
  final String? title;
  final double? amount;
  final String? type;
  final String? category;
  final DateTime? date;

  const AddTransactionScreen({
    super.key,
    this.id,
    this.title,
    this.amount,
    this.type,
    this.category,
    this.date,
  });

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}
  

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final TransactionService transactionService = TransactionService();
  String type = "Income";
  String category = "Food";

  DateTime selectedDate = DateTime.now();
  InputDecoration inputDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Theme.of(context).cardColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    ),
  );
}
  @override
void initState() {
  super.initState();

  if (widget.id != null) {
    amountController.text =
    widget.amount?.toString() ?? "";
   titleController.text =
    widget.title ?? "";

type =
    widget.type ?? "Income";

category =
    widget.category ?? "Food";

selectedDate =
    widget.date ?? DateTime.now();
}
}

  final List<String> categories = [
    "Food",
    "Shopping",
    "Travel",
    "Salary",
    "Bills",
    "Health",
    "Other",
  ];

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

     appBar: AppBar(
  title: Text(
    widget.id == null
        ? "Add Transaction"
        : "Edit Transaction",
  ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [
            // Title
            TextField(
              controller: titleController,
              decoration: inputDecoration(
  label: "Title",
  icon: Icons.title,
),
            ),

            const SizedBox(height: 20),

            // Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration(
  label: "Amount",
  icon: Icons.currency_rupee,
),
            ),

            const SizedBox(height: 20),

            // Income / Expense
            DropdownButtonFormField<String>(
              value: type,
             decoration: inputDecoration(
  label: "Transaction Type",
  icon: Icons.account_balance,
),
              items: const [
                DropdownMenuItem(
                  value: "Income",
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.green),
                      SizedBox(width: 10),
                      Text("Income"),
                    ],
                  ),
                ),

                DropdownMenuItem(
                  value: "Expense",
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.red),
                      SizedBox(width: 10),
                      Text("Expense"),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  type = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            // Category
            DropdownButtonFormField<String>(
              value: category,
              decoration: inputDecoration(
  label: "Category",
  icon: Icons.category,
),
              items: categories.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  category = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            // Date Picker
           // Date Picker
InkWell(
  onTap: pickDate,
  child: InputDecorator(
    decoration: inputDecoration(
      label: "Date",
      icon: Icons.calendar_today,
    ),
    child: Text(
      DateFormat('dd MMM yyyy').format(selectedDate),
    ),
  ),
),

const SizedBox(height: 35),

// Save Button
SizedBox(
  height: 55,
  child: ElevatedButton(
    onPressed: () async {
      if (titleController.text.isEmpty ||
          amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill all fields"),
          ),
        );
        return;
      }

      if (widget.id == null) {
        await transactionService.addTransaction(
          title: titleController.text.trim(),
          amount: double.parse(amountController.text),
          type: type,
          category: category,
          date: selectedDate,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction Added"),
          ),
        );
      } else {
        await transactionService.updateTransaction(
          id: widget.id!,
          title: titleController.text.trim(),
          amount: double.parse(amountController.text),
          type: type,
          category: category,
          date: selectedDate,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction Updated"),
          ),
        );
      }

      Navigator.pop(context);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    child: const Text(
      "Save Transaction",
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}