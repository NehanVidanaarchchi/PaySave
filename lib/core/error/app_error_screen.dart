import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../../app/app_routes.dart';

class AppErrorScreen extends StatelessWidget {

  final String message;

  const AppErrorScreen({
    super.key,
    this.message = 
      'Something went wrong.\nPlease try again.',
  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      body: Center(

        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Container(

                height:100,
                width:100,

                decoration: BoxDecoration(
                  color:
                    AppColors.danger
                    .withOpacity(.12),

                  borderRadius:
                    BorderRadius.circular(30),
                ),

                child: Icon(
                  Icons.error_outline_rounded,
                  size:55,
                  color:
                    AppColors.danger,
                ),

              ),


              const SizedBox(height:25),


              const Text(

                "Oops!",

                style: TextStyle(
                  fontSize:32,
                  fontWeight:
                    FontWeight.w900,
                ),

              ),


              const SizedBox(height:12),


              Text(

                message,

                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  color:
                    AppColors.textSecondary,
                  fontSize:15,
                ),

              ),


              const SizedBox(height:30),


              ElevatedButton(

                onPressed: (){

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (_) => false,
                  );

                },

                child:
                  const Text(
                    "Go Home",
                  ),

              )

            ],

          ),

        ),

      ),

    );

  }

}