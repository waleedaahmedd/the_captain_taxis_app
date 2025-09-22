import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:the_captain_taxis/utils/custom_colors.dart';
import 'package:the_captain_taxis/view_models/auth_view_model.dart';
import 'package:the_captain_taxis/view_models/driver_registration_view_model.dart';
import 'package:the_captain_taxis/view_models/otp_view_model.dart';

import 'app_init.dart';
import 'firebase_options.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.dualRing
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = CustomColors.primaryColor
    ..backgroundColor = CustomColors.whiteColor
    ..indicatorColor = CustomColors.primaryColor
    ..textColor = CustomColors.primaryColor
    ..maskColor = Colors.black.withValues(alpha: 0.5)
    ..maskType = EasyLoadingMaskType.custom
    ..userInteractions = false
    ..toastPosition = EasyLoadingToastPosition.bottom
    ..dismissOnTap = false;
  // ..customAnimation = CustomAnimation();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  configLoading();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => OtpViewModel()),
        ChangeNotifierProvider(create: (context) => DriverRegistrationViewModel()),
      ],
      child: AppInit(),
    ),
  );
}
