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
import '../../widgets/transaction_card.dart';


class DashboardScreen extends StatefulWidget {

  const DashboardScreen({
    super.key,
  });


  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();

}



class _DashboardScreenState extends State<DashboardScreen> {


  double totalIncome = 0;

  double totalExpense = 0;


  String selectedFilter = "All";

  String searchText = "";


  final TransactionService transactionService =
      TransactionService();


  final User? user =
      FirebaseAuth.instance.currentUser;



  String getGreeting() {

    final hour = DateTime.now().hour;


    if(hour < 12){

      return "Good Morning ☀️";

    }
    else if(hour < 17){

      return "Good Afternoon 🌤️";

    }
    else{

      return "Good Evening 🌙";

    }

  }



  Widget filterButton(String text){

    return ChoiceChip(

      label: Text(text),

      selected: selectedFilter == text,


      onSelected: (value){

        setState(() {

          selectedFilter = text;

        });

      },

    );

  }





  List<QueryDocumentSnapshot<Map<String,dynamic>>> applyFilter(

      List<QueryDocumentSnapshot<Map<String,dynamic>>> docs

      ){


    return docs.where((doc){


      String title =
      doc["title"].toString().toLowerCase();


      String category =
      doc["category"].toString().toLowerCase();



      bool searchMatch =
      title.contains(searchText) ||
          category.contains(searchText);



      if(!searchMatch){

        return false;

      }



      if(selectedFilter == "All"){

        return true;

      }



      DateTime date =
      (doc["date"] as Timestamp).toDate();



      DateTime now =
      DateTime.now();



      if(selectedFilter == "Today"){

        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

      }



      if(selectedFilter == "Week"){

        return date.isAfter(
          now.subtract(
            const Duration(days:7),
          ),
        );

      }



      if(selectedFilter == "Month"){

        return date.year == now.year &&
            date.month == now.month;

      }



      return true;


    }).toList();


  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor: AppColors.background,



      appBar: AppBar(

        backgroundColor: Colors.transparent,

        elevation:0,


        title: const Text(

          "Pocket Tracker",

          style: TextStyle(

            color: Colors.black,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),




      body: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(


        stream: transactionService.getTransactions(),



        builder:(context,snapshot){


          if(!snapshot.hasData){

            return const Center(
              child:CircularProgressIndicator(),
            );

          }



          final docs =
          snapshot.data!.docs;



          totalIncome = 0;

          totalExpense = 0;




          for(var doc in docs){


            double amount =
            (doc["amount"] as num).toDouble();



            if(doc["type"]=="Income"){

              totalIncome += amount;

            }
            else{

              totalExpense += amount;

            }


          }



          double balance =
              totalIncome - totalExpense;



          final filteredDocs =
          applyFilter(docs);




          return ListView(

            padding:
            const EdgeInsets.all(20),


            children:[



              Text(

                getGreeting(),

                style:
                const TextStyle(

                  color:Colors.grey,

                  fontSize:16,

                ),

              ),



              const SizedBox(height:5),




              Text(

                user?.email?.split("@")[0] ?? "User",

                style:
                const TextStyle(

                  fontSize:30,

                  fontWeight:FontWeight.bold,

                ),

              ),




              const SizedBox(height:25),




              Container(

                padding:
                const EdgeInsets.all(20),


                decoration:
                BoxDecoration(

                  color:AppColors.primary,

                  borderRadius:
                  BorderRadius.circular(20),

                ),



                child:Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children:[


                    const Text(

                      "Total Balance",

                      style:
                      TextStyle(

                        color:Colors.white70,

                      ),

                    ),



                    const SizedBox(height:10),



                    Text(

                      "₹${balance.toStringAsFixed(2)}",

                      style:
                      const TextStyle(

                        color:Colors.white,

                        fontSize:32,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),


                  ],

                ),

              ),




              const SizedBox(height:25),




              Row(

                children:[


                  Expanded(

                    child:Card(

                      child:ListTile(

                        title:
                        const Text("Income"),

                        subtitle:
                        Text(
                          "₹${totalIncome.toStringAsFixed(2)}",
                        ),

                      ),

                    ),

                  ),




                  const SizedBox(width:10),




                  Expanded(

                    child:Card(

                      child:ListTile(

                        title:
                        const Text("Expense"),

                        subtitle:
                        Text(
                          "₹${totalExpense.toStringAsFixed(2)}",
                        ),

                      ),

                    ),

                  ),


                ],

              ),





              const SizedBox(height:20),




              StreamBuilder<BudgetModel?>(


                stream:
                BudgetService().getBudget(
                  FirebaseAuth.instance.currentUser!.uid,
                ),



                builder:(context,budgetSnapshot){


                  if(!budgetSnapshot.hasData ||
                      budgetSnapshot.data==null){


                    return Card(

                      child:ListTile(


                        title:
                        const Text(
                          "No Budget Found",
                        ),


                        subtitle:
                        const Text(
                          "Create your monthly budget",
                        ),



                        trailing:
                        ElevatedButton(


                          onPressed:(){


                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder:(_)=>
                                const SetBudgetScreen(),

                              ),

                            );


                          },


                          child:
                          const Text(
                            "Create",
                          ),


                        ),

                      ),

                    );


                  }



                  return BudgetCard(

                    budget:
                    budgetSnapshot.data!,

                    spent:
                    totalExpense,

                  );


                },


              ),





              const SizedBox(height:25),





              Row(

                mainAxisAlignment:
                MainAxisAlignment.spaceAround,


                children:[

                  filterButton("All"),

                  filterButton("Today"),

                  filterButton("Week"),

                  filterButton("Month"),

                ],

              ),




              const SizedBox(height:15),




              TextField(


                decoration:
                const InputDecoration(


                  hintText:
                  "Search transaction",


                  prefixIcon:
                  Icon(Icons.search),


                  border:
                  OutlineInputBorder(),


                ),



                onChanged:(value){


                  setState((){

                    searchText =
                        value.toLowerCase();

                  });


                },


              ),





              const SizedBox(height:25),





              const Text(

                "Recent Transactions",

                style:
                TextStyle(

                  fontSize:22,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),




              const SizedBox(height:15),





              ...filteredDocs.map((transaction){


                return TransactionCard(

                  transaction: transaction,

                );


              }).toList(),



            ],

          );

        },


      ),




      floatingActionButton:
      FloatingActionButton(

        backgroundColor:
        AppColors.primary,


        onPressed:(){


          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(_)=>
              const AddTransactionScreen(),

            ),

          );


        },


        child:
        const Icon(Icons.add),


      ),


    );


  }

}