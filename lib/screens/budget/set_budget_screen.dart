import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/budget_model.dart';
import '../../services/budget_service.dart';
import '../../utils/app_colors.dart';


class SetBudgetScreen extends StatefulWidget {

  const SetBudgetScreen({super.key});


  @override
  State<SetBudgetScreen> createState() =>
      _SetBudgetScreenState();

}



class _SetBudgetScreenState extends State<SetBudgetScreen> {


  final TextEditingController budgetController =
      TextEditingController();


  final BudgetService budgetService =
      BudgetService();



  Future<void> saveBudget() async {


    if (budgetController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
            "Enter budget amount",
          ),
        ),

      );

      return;

    }



    final user =
        FirebaseAuth.instance.currentUser;



    if (user == null) {

      return;

    }




    try {


      final budget = BudgetModel(

        id: "current",


        monthlyLimit:
            double.parse(
              budgetController.text.trim(),
            ),


        month:
            DateTime.now()
                .month
                .toString(),


        createdAt:
            Timestamp.now(),

      );





      await budgetService.addBudget(
        user.uid,
        budget,
      );





      if(mounted){


        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Budget Saved Successfully",
            ),

          ),

        );



        Navigator.pop(context);


      }




    } catch(e) {


      if(mounted){

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content:
                Text("Error: $e"),

          ),

        );

      }


    }


  }






  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
          AppColors.background,



      appBar: AppBar(

        title:
            const Text(
              "Set Monthly Budget",
            ),


        backgroundColor:
            AppColors.primary,


        foregroundColor:
            Colors.white,

      ),




      body: Padding(

        padding:
            const EdgeInsets.all(20),



        child: Column(


          children: [



            TextField(


              controller:
                  budgetController,



              keyboardType:
                  TextInputType.number,



              decoration:
                  InputDecoration(


                    labelText:
                        "Enter Budget Amount",



                    prefixText:
                        "₹ ",



                    border:
                        OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(12),

                        ),


                  ),


            ),





            const SizedBox(height:30),





            SizedBox(


              width:
                  double.infinity,



              child:
                  ElevatedButton(



                    style:
                        ElevatedButton.styleFrom(


                          backgroundColor:
                              AppColors.primary,



                          padding:
                              const EdgeInsets.all(15),


                        ),




                    onPressed:
                        saveBudget,




                    child:
                        const Text(


                          "Save Budget",



                          style:
                              TextStyle(


                                color:
                                    Colors.white,



                                fontSize:
                                    18,


                              ),


                        ),


                  ),


            )



          ],


        ),


      ),


    );

  }




  @override
  void dispose() {

    budgetController.dispose();

    super.dispose();

  }

}