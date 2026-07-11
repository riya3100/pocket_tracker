import 'package:flutter/material.dart';

import '../models/budget_model.dart';
import '../utils/app_colors.dart';
import '../screens/budget/set_budget_screen.dart';


class BudgetCard extends StatelessWidget {

  final BudgetModel budget;
  final double spent;


  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
  });



  @override
  Widget build(BuildContext context) {


    double remaining =
        budget.monthlyLimit - spent;


    double progress = budget.monthlyLimit == 0
        ? 0
        : spent / budget.monthlyLimit;


    if (progress > 1) {
      progress = 1;
    }



    return Card(

      elevation: 3,


      child: Padding(

        padding: const EdgeInsets.all(18),


        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,


          children: [



            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,


              children: [


                const Text(

                  "Monthly Budget",

                  style: TextStyle(

                    fontSize: 20,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),



                Icon(

                  Icons.account_balance_wallet,

                  color:
                      AppColors.primary,

                ),


              ],

            ),




            const SizedBox(height:15),




            Text(

              "Budget: ₹${budget.monthlyLimit.toStringAsFixed(0)}",

              style: const TextStyle(

                fontSize:16,

              ),

            ),




            Text(

              "Spent: ₹${spent.toStringAsFixed(0)}",

              style: const TextStyle(

                fontSize:16,

              ),

            ),





            Text(

              "Remaining: ₹${remaining.toStringAsFixed(0)}",


              style: TextStyle(

                fontSize:16,


                color: remaining < 0
                    ? Colors.red
                    : Colors.green,

              ),

            ),





            const SizedBox(height:15),





            LinearProgressIndicator(

              value: progress,

              minHeight:10,


              borderRadius:
                  BorderRadius.circular(10),


              backgroundColor:
                  Colors.grey.shade300,


              color: progress >= 1
                  ? Colors.red
                  : AppColors.primary,

            ),





            const SizedBox(height:8),





            Text(
  "${(progress * 100).toStringAsFixed(0)}% used",

  style: TextStyle(
    fontWeight: FontWeight.bold,

    color: progress >= 1
        ? Colors.red
        : progress >= 0.8
            ? Colors.orange
            : Colors.green,
  ),
),


const SizedBox(height: 10),



if (progress >= 1)

  Container(

    width: double.infinity,

    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(

      color: Colors.red.shade100,

      borderRadius:
          BorderRadius.circular(10),

    ),


    child: const Text(

      "⚠️ Budget exceeded!",

      style: TextStyle(

        color: Colors.red,

        fontWeight: FontWeight.bold,

      ),

    ),

  )

else if (progress >= 0.8)

  Container(

    width: double.infinity,

    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(

      color: Colors.orange.shade100,

      borderRadius:
          BorderRadius.circular(10),

    ),


    child: const Text(

      "⚠️ You have used 80% of your budget",

      style: TextStyle(

        color: Colors.orange,

        fontWeight: FontWeight.bold,

      ),

    ),

  ),





            const SizedBox(height:15),






            SizedBox(

              width: double.infinity,


              child: ElevatedButton(


                style: ElevatedButton.styleFrom(

                  backgroundColor:
                      AppColors.primary,


                  padding:
                      const EdgeInsets.symmetric(
                        vertical:12,
                      ),



                  shape: RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(12),

                  ),

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

                  "Update Budget",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize:16,

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