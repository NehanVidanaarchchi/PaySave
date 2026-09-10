import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/validation_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/saving_provider.dart';


class AddSavingGoalScreen extends StatefulWidget {

  const AddSavingGoalScreen({
    super.key,
  });


  @override
  State<AddSavingGoalScreen> createState() =>
      _AddSavingGoalScreenState();

}



class _AddSavingGoalScreenState
    extends State<AddSavingGoalScreen> {


  final _formKey =
      GlobalKey<FormState>();


  final _goalNameController =
      TextEditingController();


  final _targetAmountController =
      TextEditingController();


  final _savedAmountController =
      TextEditingController(text: "0");


  final _monthlyTargetController =
      TextEditingController();


  final _noteController =
      TextEditingController();



  DateTime _targetDate =
      DateTime.now()
          .add(const Duration(days:180));



  @override
  void initState(){

    super.initState();


    _targetAmountController.addListener(
      (){
        setState((){});
      },
    );


    _savedAmountController.addListener(
      (){
        setState((){});
      },
    );

  }



  @override
  void dispose(){

    _goalNameController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
    _monthlyTargetController.dispose();
    _noteController.dispose();

    super.dispose();

  }




  double get targetAmount =>
      double.tryParse(
        _targetAmountController.text
      ) ?? 0;



  double get savedAmount =>
      double.tryParse(
        _savedAmountController.text
      ) ?? 0;



  double get progress {

    if(targetAmount <=0)
      return 0;

    return (savedAmount / targetAmount)
        .clamp(0,1);

  }



  Future<void> _pickDate() async {


    final picked =
    await showDatePicker(

      context: context,

      initialDate:_targetDate,

      firstDate:DateTime.now(),

      lastDate:
      DateTime(
        DateTime.now().year+10,
      ),

      builder:(context,child){

        return Theme(

          data:
          ThemeData.dark(),

          child:child!,

        );

      },

    );


    if(picked == null)
      return;


    setState((){

      _targetDate=picked;

    });


  }




  Future<void> _saveGoal() async {


    FocusScope.of(context).unfocus();


    if(!_formKey.currentState!.validate())
      return;



    final provider =
        context.read<SavingProvider>();



    final success =
    await provider.addSavingGoal(

      goalName:
      _goalNameController.text.trim(),

      targetAmount:
      targetAmount,

      savedAmount:
      savedAmount,

      monthlyTarget:
      double.tryParse(
        _monthlyTargetController.text,
      ) ?? 0,


      targetDate:
      _targetDate,


      note:
      _noteController.text.trim(),

    );



    if(!mounted)
      return;



    if(success){

      Navigator.pop(context);

    }

    else{

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            provider.errorMessage ??
                "Failed to save goal",
          ),

          backgroundColor:
          AppColors.danger,

        ),

      );

    }


  }





  @override
  Widget build(BuildContext context){


    final provider =
        context.watch<SavingProvider>();



    return Scaffold(

      backgroundColor:
      Colors.black,


      appBar:AppBar(

        backgroundColor:
        Colors.black,

        elevation:0,

        foregroundColor:
        Colors.white,

        title:
        const Text(

          "Add Saving Goal",

          style:TextStyle(

            fontWeight:
            FontWeight.w900,

          ),

        ),

      ),



      body:ListView(

        physics:
        const BouncingScrollPhysics(),


        padding:
        const EdgeInsets.fromLTRB(
          22,
          10,
          22,
          40,
        ),


        children:[



          const Text(

            "Set a target amount and track your progress every month.",

            style:TextStyle(

              color:
              Color(0xffA1A1A1),

              fontSize:14,

              fontWeight:
              FontWeight.w600,

            ),

          ),



          const SizedBox(height:22),




          _GoalPreviewCard(

            targetAmount:
            targetAmount,

            savedAmount:
            savedAmount,

            progress:
            progress,

          ),




          const SizedBox(height:20),




          Container(

            padding:
            const EdgeInsets.all(
              18,
            ),


            decoration:
            BoxDecoration(

              color:
              const Color(0xff111111),


              borderRadius:
              BorderRadius.circular(28),


              border:
              Border.all(

                color:
                const Color(0xff292929),

              ),

            ),


            child:
            Form(

              key:_formKey,


              child:
              Column(

                children:[



                  CustomTextField(

                    controller:
                    _goalNameController,

                    label:
                    "Goal Name",

                    hint:
                    "New Laptop",

                    icon:
                    Icons.flag_rounded,


                    validator:(v){

                      return ValidationHelper.requiredField(
                        v,
                        fieldName:"Goal name",
                      );

                    },

                  ),



                  const SizedBox(height:14),



                  CustomTextField(

                    controller:
                    _targetAmountController,

                    label:
                    "Target Amount",

                    hint:
                    "250000",

                    icon:
                    Icons.track_changes_rounded,

                    keyboardType:
                    TextInputType.number,


                    validator:
                    ValidationHelper.amount,

                  ),



                  const SizedBox(height:14),



                  CustomTextField(

                    controller:
                    _savedAmountController,

                    label:
                    "Already Saved",

                    hint:
                    "0",

                    icon:
                    Icons.savings_rounded,

                    keyboardType:
                    TextInputType.number,

                  ),




                  const SizedBox(height:14),




                  CustomTextField(

                    controller:
                    _monthlyTargetController,

                    label:
                    "Monthly Saving Target",

                    hint:
                    "5000",

                    icon:
                    Icons.calendar_month_rounded,


                    keyboardType:
                    TextInputType.number,

                  ),




                  const SizedBox(height:14),




                  _DateBox(

                    title:
                    "Target Date",

                    value:
                    "${_targetDate.day}/${_targetDate.month}/${_targetDate.year}",


                    onTap:
                    _pickDate,

                  ),




                  const SizedBox(height:14),




                  CustomTextField(

                    controller:
                    _noteController,

                    label:
                    "Note",

                    hint:
                    "Optional note",

                    icon:
                    Icons.notes_rounded,

                    maxLines:
                    3,

                  ),




                  const SizedBox(height:24),




                  CustomButton(

                    text:
                    "Save Goal",

                    icon:
                    Icons.check_rounded,

                    isLoading:
                    provider.isLoading,


                    onPressed:
                    _saveGoal,

                  ),


                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}






class _GoalPreviewCard extends StatelessWidget {


  final double targetAmount;

  final double savedAmount;

  final double progress;



  const _GoalPreviewCard({

    required this.targetAmount,

    required this.savedAmount,

    required this.progress,

  });



  @override
  Widget build(BuildContext context){


    final remaining =
    (targetAmount-savedAmount)
        .clamp(0,double.infinity);



    return Container(


      padding:
      const EdgeInsets.all(24),



      decoration:
      BoxDecoration(

        gradient:
        const LinearGradient(

          colors:[

            Color(0xff1A1A1A),

            Color(0xff0B0B0B),

          ],

        ),


        borderRadius:
        BorderRadius.circular(30),


        border:
        Border.all(

          color:
          const Color(0xff292929),

        ),

      ),



      child:
      Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,


        children:[


          const Text(

            "Goal Preview",

            style:
            TextStyle(

              color:
              Color(0xffA1A1A1),

              fontWeight:
              FontWeight.w700,

            ),

          ),



          const SizedBox(height:8),




          Text(

            "${(progress*100).toStringAsFixed(0)}%",

            style:
            const TextStyle(

              color:
              Colors.white,

              fontSize:
              38,

              fontWeight:
              FontWeight.w900,

            ),

          ),



          const SizedBox(height:10),



          Text(

            "${CurrencyHelper.format(savedAmount)} saved • ${CurrencyHelper.format(remaining.toDouble())} remaining",

            style:
            const TextStyle(

              color:
              Color(0xffA1A1A1),

              fontWeight:
              FontWeight.w700,

            ),

          ),



          const SizedBox(height:18),



          ClipRRect(

            borderRadius:
            BorderRadius.circular(50),


            child:
            LinearProgressIndicator(

              value:
              progress,


              minHeight:
              10,


              backgroundColor:
              Colors.white12,


              color:
              Colors.white,


            ),

          ),


        ],

      ),

    );


  }

}






class _DateBox extends StatelessWidget {


  final String title;

  final String value;

  final VoidCallback onTap;



  const _DateBox({

    required this.title,

    required this.value,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context){


    return InkWell(

      onTap:onTap,


      borderRadius:
      BorderRadius.circular(18),


      child:
      Container(


        padding:
        const EdgeInsets.all(16),


        decoration:
        BoxDecoration(

          color:
          const Color(0xff111111),


          borderRadius:
          BorderRadius.circular(18),


          border:
          Border.all(

            color:
            const Color(0xff292929),

          ),

        ),


        child:
        Row(

          children:[


            const Icon(

              Icons.calendar_month,

              color:
              Colors.white,

            ),



            const SizedBox(width:12),



            Expanded(

              child:
              Text(

                title,

                style:
                const TextStyle(

                  color:
                  Color(0xffA1A1A1),

                ),

              ),

            ),



            Text(

              value,

              style:
              const TextStyle(

                color:
                Colors.white,

                fontWeight:
                FontWeight.bold,

              ),

            ),

          ],

        ),

      ),

    );


  }

}