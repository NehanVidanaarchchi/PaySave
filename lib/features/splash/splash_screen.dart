import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';


class SplashScreen extends StatefulWidget {

  const SplashScreen({
    super.key,
  });


  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();

}



class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {


  late final AnimationController _controller;

  late final Animation<double> _scaleAnimation;

  late final Animation<double> _fadeAnimation;


  double _progress = 0;


  String _loadingText =
      "Preparing your dashboard...";



  final List<String> _steps = [

    "Preparing your dashboard...",

    "Loading your finance data...",

    "Checking your goals...",

    "Almost ready..."

  ];



  @override
  void initState() {

    super.initState();



    _controller =
        AnimationController(

          vsync: this,

          duration:
          const Duration(
            milliseconds: 1000,
          ),

        );



    _scaleAnimation =
        CurvedAnimation(

          parent: _controller,

          curve:
          Curves.easeOutBack,

        );



    _fadeAnimation =
        CurvedAnimation(

          parent: _controller,

          curve:
          Curves.easeOut,

        );



    _controller.forward();


    _startLoading();

  }





  Future<void> _startLoading() async {


    for(int i = 0; i < _steps.length; i++){


      await Future.delayed(

        const Duration(
          milliseconds:450,
        ),

      );


      if(!mounted)
        return;


      setState((){

        _progress =
            (i + 1) /
            _steps.length;


        _loadingText =
            _steps[i];

      });


    }



    await _goNext();

  }





  Future<void> _goNext() async {


    await Future.delayed(

      const Duration(
        milliseconds:500,
      ),

    );


    if(!mounted)
      return;



    final user =
        FirebaseAuth.instance.currentUser;



    if(user != null){

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
      );

    }

    else{

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.onboarding,
      );

    }


  }





  @override
  void dispose(){

    _controller.dispose();

    super.dispose();

  }





  @override
  Widget build(BuildContext context){


    return Scaffold(

      backgroundColor:
      Colors.black,



      body:
      Container(

        width:
        double.infinity,


        color:
        Colors.black,



        child:
        SafeArea(

          child:
          Padding(

            padding:
            const EdgeInsets.all(
              AppSizes.paddingL,
            ),



            child:
            Column(

              children:[



                const Spacer(),




                ScaleTransition(

                  scale:
                  _scaleAnimation,


                  child:
                  FadeTransition(

                    opacity:
                    _fadeAnimation,


                    child:
                    Container(

                      height:
                      130,


                      width:
                      130,



                      padding:
                      const EdgeInsets.all(
                        22,
                      ),



                      decoration:
                      BoxDecoration(


                        color:
                        const Color(
                          0xff111111,
                        ),



                        borderRadius:
                        BorderRadius.circular(
                          38,
                        ),



                        border:
                        Border.all(

                          color:
                          const Color(
                            0xff292929,
                          ),

                        ),



                        boxShadow:[


                          BoxShadow(

                            color:
                            Colors.white
                                .withOpacity(
                                0.08
                            ),


                            blurRadius:
                            40,


                            offset:
                            const Offset(
                              0,
                              15,
                            ),

                          )


                        ],


                      ),




                      clipBehavior:
                      Clip.antiAlias,



                      child:
                      Image.asset(

                        'assets/images/paysave_logo.png',

                        fit:
                        BoxFit.contain,


                        errorBuilder:
                            (_,__,___){


                          return const Icon(

                            Icons.account_balance_wallet_rounded,

                            color:
                            Colors.white,


                            size:
                            60,

                          );


                        },

                      ),


                    ),

                  ),

                ),





                const SizedBox(
                  height:28,
                ),





                const Text(

                  AppStrings.appName,


                  style:
                  TextStyle(

                    color:
                    Colors.white,


                    fontSize:
                    38,


                    fontWeight:
                    FontWeight.w900,


                    letterSpacing:
                    -1,

                  ),

                ),




                const SizedBox(
                  height:8,
                ),




                const Text(

                  AppStrings.appSubtitle,


                  textAlign:
                  TextAlign.center,


                  style:
                  TextStyle(

                    color:
                    Color(
                      0xffA1A1A1,
                    ),


                    fontSize:
                    14,


                    fontWeight:
                    FontWeight.w600,

                  ),

                ),





                const Spacer(),





                Text(

                  _loadingText,


                  style:
                  const TextStyle(

                    color:
                    Colors.white,


                    fontSize:
                    13,


                    fontWeight:
                    FontWeight.w700,

                  ),

                ),





                const SizedBox(
                  height:16,
                ),





                SizedBox(

                  width:
                  230,


                  child:
                  ClipRRect(

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),


                    child:
                    LinearProgressIndicator(


                      value:
                      _progress,


                      minHeight:
                      7,


                      backgroundColor:
                      const Color(
                        0xff292929,
                      ),



                      valueColor:
                      const AlwaysStoppedAnimation(
                        Colors.white,
                      ),


                    ),

                  ),

                ),





                const SizedBox(
                  height:10,
                ),





                Text(

                  "${(_progress * 100).toInt()}%",


                  style:
                  const TextStyle(

                    color:
                    Color(
                      0xff777777,
                    ),


                    fontSize:
                    12,


                    fontWeight:
                    FontWeight.bold,

                  ),

                ),





                const SizedBox(
                  height:26,
                ),


              ],

            ),

          ),

        ),

      ),

    );

  }

}