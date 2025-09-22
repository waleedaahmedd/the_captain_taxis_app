import 'package:flutter/material.dart';
import 'package:the_captain_taxis/views/driver_registration_stepper_screen.dart';
import 'package:the_captain_taxis/views/home_screen.dart';
import 'package:the_captain_taxis/views/login_screen.dart';
import 'package:the_captain_taxis/views/otp_screen.dart';
import 'package:the_captain_taxis/views/splash_screen.dart';

const String splashRoute = '/';
const String loginRoute = '/login';
const String otpRoute = '/otp';
const String registrationStepperRoute = '/registration-stepper';
const String homeRoute = '/home';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otpRoute:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case registrationStepperRoute:
        return MaterialPageRoute(builder: (_) => const RegistrationStepperScreen());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/tasting_details':
      /*return MaterialPageRoute(
            builder: (_) => const TastingDetailsScreen(),
            settings: const RouteSettings(name: '/tasting_details'));*/
      case '/wines_details':
      /*return MaterialPageRoute(
            builder: (_) => WinesDetailScreen(
                  reviewButton: args,
                ));*/

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return const Scaffold(
          body: Center(child: Text('Something wrong in routes')),
        );
      },
    );
  }
}
