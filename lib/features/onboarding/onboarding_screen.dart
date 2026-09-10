import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_button.dart';


class OnboardingScreen extends StatelessWidget {

  const OnboardingScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,


      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(
            AppSizes.paddingL,
          ),


          child: Column(

            children: [


              // LOGIN BUTTON

              Align(

                alignment: Alignment.centerRight,


                child: TextButton(

                  onPressed: () {

                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    );

                  },


                  child: const Text(

                    "Login",

                    style: TextStyle(

                      color: Colors.white,

                      fontWeight: FontWeight.w800,

                    ),

                  ),

                ),

              ),



              const Spacer(),




              // LOGO CARD

              Container(

                height: 300,

                width: double.infinity,


                decoration: BoxDecoration(

                  color: const Color(0xff111111),


                  borderRadius:
                  BorderRadius.circular(36),


                  border: Border.all(

                    color:
                    const Color(0xff292929),

                  ),


                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.white.withOpacity(0.05),

                      blurRadius: 40,

                      offset:
                      const Offset(0, 20),

                    ),

                  ],

                ),



                child: Center(

                  child: Container(

                    height: 190,

                    width: 190,


                    padding:
                    const EdgeInsets.all(18),



                    decoration: BoxDecoration(

                      color: Colors.black,


                      borderRadius:
                      BorderRadius.circular(45),



                      border: Border.all(

                        color:
                        const Color(0xff333333),

                      ),

                    ),
                    clipBehavior: Clip.antiAlias,



                    child: Image.asset(

                      "assets/images/paysave_logo.png",


                      fit:
                      BoxFit.contain,



                      errorBuilder:
                          (_, __, ___) {


                        return const Icon(

                          Icons.account_balance_wallet_rounded,

                          color:
                          Colors.white,

                          size:
                          80,

                        );

                      },

                    ),

                  ),

                ),

              ),





              const SizedBox(
                height: 45,
              ),





              const Text(

                "Plan your money\nbefore you spend",


                textAlign:
                TextAlign.center,


                style: TextStyle(

                  color:
                  Colors.white,


                  fontSize:
                  34,


                  height:
                  1.05,


                  fontWeight:
                  FontWeight.w900,


                  letterSpacing:
                  -1,

                ),

              ),





              const SizedBox(
                height: 18,
              ),





              const Text(

                "Manage income, bills, savings,\nand reminders in one simple app.",


                textAlign:
                TextAlign.center,


                style: TextStyle(

                  color:
                  Color(0xffA1A1A1),


                  fontSize:
                  15,


                  height:
                  1.5,


                  fontWeight:
                  FontWeight.w600,

                ),

              ),





              const Spacer(),






              CustomButton(

                text:
                "Get Started",


                icon:
                Icons.arrow_forward_rounded,


                onPressed: () {

                  Navigator.pushReplacementNamed(

                    context,

                    AppRoutes.register,

                  );

                },


              ),





              const SizedBox(
                height: 16,
              ),





              const Text(

                "No bank connection.\nOnly smart planning and reminders.",


                textAlign:
                TextAlign.center,


                style: TextStyle(

                  color:
                  Color(0xff666666),


                  fontSize:
                  12,


                  height:
                  1.4,


                  fontWeight:
                  FontWeight.w600,

                ),

              ),




            ],

          ),

        ),

      ),

    );

  }

}