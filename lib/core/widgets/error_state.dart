import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });


  @override
  Widget build(BuildContext context) {

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Container(
              height: 90,
              width: 90,

              decoration: BoxDecoration(

                color: AppColors.danger
                    .withValues(alpha: 0.12),

                borderRadius:
                    BorderRadius.circular(28),

              ),

              child: const Icon(
                Icons.cloud_off_rounded,
                size: 45,
                color: AppColors.danger,
              ),

            ),


            const SizedBox(height: 20),


            const Text(
              'Something went wrong',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),


            const SizedBox(height: 8),


            Text(
              message,

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),


            const SizedBox(height: 22),


            if(onRetry != null)

              SizedBox(
                height: 48,
                width: 150,

                child: ElevatedButton.icon(

                  onPressed: onRetry,

                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),

                  label: const Text(
                    'Retry',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                ),
              )

          ],

        ),

      ),
    );
  }
}