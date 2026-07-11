import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../utils/app_colors.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Statistics"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("transactions")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No Data Found"),
            );
          }


          final docs = snapshot.data!.docs;

          double income = 0;
          double expense = 0;

          Map<String, double> categoryTotals = {};


          for (var doc in docs) {

            final data = doc.data() as Map<String, dynamic>;

            double amount =
                (data["amount"] ?? 0).toDouble();

            String type =
                data["type"] ?? "";

            String category =
                data["category"] ?? "Other";


            if (type == "Income") {

              income += amount;

            } else {

              expense += amount;

              categoryTotals[category] =
                  (categoryTotals[category] ?? 0) + amount;
            }
          }


          double balance = income - expense;


          return ListView(
            padding: const EdgeInsets.all(20),

            children: [


              // Balance Card

              Card(
                elevation: 3,

                child: ListTile(

                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,

                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                    ),
                  ),


                  title: const Text(
                    "Current Balance",
                  ),


                  trailing: Text(
                    "₹${balance.toStringAsFixed(2)}",

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),



              const SizedBox(height:20),



              // Income Expense Cards


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
                              size:30,
                            ),


                            const SizedBox(height:10),


                            const Text("Income"),


                            const SizedBox(height:5),


                            Text(

                              "₹${income.toStringAsFixed(2)}",

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:18,
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),



                  const SizedBox(width:15),



                  Expanded(

                    child: Card(

                      child: Padding(

                        padding: const EdgeInsets.all(18),

                        child: Column(

                          children: [

                            const Icon(
                              Icons.arrow_upward,
                              color: AppColors.expense,
                              size:30,
                            ),


                            const SizedBox(height:10),


                            const Text("Expense"),


                            const SizedBox(height:5),


                            Text(

                              "₹${expense.toStringAsFixed(2)}",

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:18,
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  )

                ],
              ),



              const SizedBox(height:30),



              // Pie Chart


              if(income > 0 || expense > 0)

                SizedBox(

                  height:250,

                  child: PieChart(

                    PieChartData(

                      centerSpaceRadius:55,

                      sectionsSpace:3,


                      sections:[


                        PieChartSectionData(

                          value:income,

                          color:AppColors.primary,

                          radius:70,

                          title:"Income",

                          titleStyle:const TextStyle(

                            color:Colors.white,

                            fontWeight:FontWeight.bold,

                          ),
                        ),



                        PieChartSectionData(

                          value:expense,

                          color:AppColors.expense,

                          radius:70,

                          title:"Expense",

                          titleStyle:const TextStyle(

                            color:Colors.white,

                            fontWeight:FontWeight.bold,

                          ),
                        ),


                      ],
                    ),
                  ),
                ),




              const SizedBox(height:30),




              const Text(

                "Expenses by Category",

                style:TextStyle(

                  fontSize:22,

                  fontWeight:FontWeight.bold,

                ),
              ),



              const SizedBox(height:15),



              if(categoryTotals.isEmpty)

                const Center(

                  child:Padding(

                    padding:EdgeInsets.all(40),

                    child:Text(

                      "No Expense Data",

                      style:TextStyle(

                        fontSize:18,

                        color:Colors.grey,

                      ),
                    ),
                  ),
                ),




              ...categoryTotals.entries.map((entry){


                return Card(

                  margin:const EdgeInsets.only(bottom:10),


                  child:ListTile(

                    leading:const CircleAvatar(

                      backgroundColor:
                          AppColors.primaryLight,


                      child:Icon(

                        Icons.pie_chart,

                        color:AppColors.primary,

                      ),
                    ),


                    title:Text(entry.key),


                    trailing:Text(

                      "₹${entry.value.toStringAsFixed(2)}",

                      style:const TextStyle(

                        fontWeight:FontWeight.bold,

                        fontSize:16,

                      ),
                    ),
                  ),
                );

              })

            ],
          );
        },
      ),
    );
  }
}