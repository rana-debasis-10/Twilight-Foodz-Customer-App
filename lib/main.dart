import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilight_foodz_customer/data/app_routes.dart';
import 'package:twilight_foodz_customer/views/pages/failure.dart';
import 'package:twilight_foodz_customer/views/pages/generate_otp.dart';
import 'package:twilight_foodz_customer/views/pages/home.dart';
import 'package:twilight_foodz_customer/views/pages/order_summary.dart';
import 'package:twilight_foodz_customer/views/pages/payment.dart';
import 'package:twilight_foodz_customer/views/pages/registration.dart';
import 'package:twilight_foodz_customer/views/pages/verification.dart';
import 'package:twilight_foodz_customer/views/pages/error.dart';
import 'package:twilight_foodz_customer/views/widgets/page_transition.dart';

import 'views/pages/welcome.dart';

void main() {
  return runApp(const TwilightApp());
}

class TwilightApp extends StatelessWidget {
  const TwilightApp({super.key});

  Future<String?> fetchCustomer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchCustomer(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {

          return Center(child: Text("Corrupted Data"));

        }

        String? jwt = snapshot.data;

        return MaterialApp(

          debugShowCheckedModeBanner: false,

          initialRoute: jwt == null ? AppRoutes.welcome : AppRoutes.home,

          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.welcome:
                return PageTransitions.getSlideTransitionOfPage(
                  page: Welcome(),
                );

              case AppRoutes.verification:
                return PageTransitions.getSlideTransitionOfPage(
                  page: Verification(phoneNumber: settings.arguments as String),
                );

              case AppRoutes.generateOtp:
                return PageTransitions.getSlideTransitionOfPage(
                  page: GenerateOtp(),
                );

              case AppRoutes.home:
                return PageTransitions.getSlideTransitionOfPage(
                  page: Home(jwt: settings.arguments as String),
                );

              case AppRoutes.failure:
                return PageTransitions.getSlideTransitionOfPage(
                  page: const Failure(),
                );

              case AppRoutes.registration:
                return PageTransitions.getSlideTransitionOfPage(
                  page: const Registration(),
                );

              case AppRoutes.orderSummary:
                return PageTransitions.getSlideTransitionOfPage(
                  page: const OrderSummary(),
                );

              case AppRoutes.payment:
                return PageTransitions.getSlideTransitionOfPage(
                  page: Payment(),
                );

              default:
                return PageTransitions.getSlideTransitionOfPage(page: Error());
            }
          },
        );
      },
    );
  }
}
