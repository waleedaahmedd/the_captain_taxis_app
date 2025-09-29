import 'package:flutter/material.dart';
import 'package:the_captain_taxis/views/driver_screens/driver_documents_screen.dart';
import 'package:the_captain_taxis/views/driver_screens/driver_stepper_screen.dart';
import 'package:the_captain_taxis/views/driver_screens/driver_vehicle_screen.dart';
import 'package:the_captain_taxis/views/login_screen.dart';
import 'package:the_captain_taxis/views/otp_screen.dart';
import 'package:the_captain_taxis/views/splash_screen.dart';
import 'package:the_captain_taxis/views/user_screens/user_home_screen.dart';


const String splashRoute = '/';
const String loginRoute = '/login';
const String otpRoute = '/otp';
const String driverRegistrationStepperRoute = '/driver-registration-stepper';
const String homeRoute = '/home';
const String driverDocumentsRoutes = '/driver-documents';
const String driverVehicleRoutes = '/driver-vehicle';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otpRoute:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case driverRegistrationStepperRoute:
        return MaterialPageRoute(
          builder: (_) => const DriverStepperScreen(),
        );
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());
      case driverDocumentsRoutes:
        return MaterialPageRoute(
          builder: (_) => DriverDocumentsScreen.withAppBar(),
        );
      case driverVehicleRoutes:
        return MaterialPageRoute(
          builder: (_) => DriverVehicleScreen.withAppBar(),
        );
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
