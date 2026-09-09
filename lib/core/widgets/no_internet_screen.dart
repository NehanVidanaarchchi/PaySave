import 'package:flutter/material.dart';

import '../constants/app_colors.dart';


class NoInternetScreen extends StatelessWidget {

  final VoidCallback onRetry;


  const NoInternetScreen({
    super.key,
    required this.onRetry,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
          AppColors.background,


      body: Center(

        child: Padding(

          padding:
              const EdgeInsets.all(30),


          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,


            children: [


              Container(

                height:100,
                width:100,


                decoration: BoxDecoration(

                  color:
                    AppColors.warning
                    .withValues(alpha:0.15),


                  borderRadius:
                    BorderRadius.circular(30),

                ),


                child: const Icon(

                  Icons.wifi_off_rounded,

                  size:50,

                  color:
                    AppColors.warning,

                ),

              ),



              const SizedBox(height:25),



              const Text(

                "No Internet Connection",

                style: TextStyle(

                  fontSize:25,

                  fontWeight:
                      FontWeight.w900,

                  color:
                    AppColors.textPrimary,

                ),

              ),



              const SizedBox(height:10),



              const Text(

                "Please check your internet connection and try again.",

                textAlign:
                    TextAlign.center,


                style: TextStyle(

                  color:
                    AppColors.textSecondary,

                  fontSize:14,

                ),

              ),



              const SizedBox(height:30),



              ElevatedButton.icon(

                onPressed:onRetry,


                icon:
                    const Icon(
                      Icons.refresh_rounded,
                    ),


                label:
                    const Text(
                      "Retry",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

              )

            ],

          ),

        ),

      ),

    );

  }

}