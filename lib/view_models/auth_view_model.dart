import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../services/auth_service.dart';
import '../utils/enums.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _loginWith = LoginWith.phone.value;

  String _countryCode = '+61';

  bool _isTermsAccepted = false;

  bool _isDriverLogin = false;

  bool get getIsDriverLogin => _isDriverLogin;

  set setIsDriverLogin(bool value) {
    _isDriverLogin = value;
  }

  String get getLoginWith => _loginWith;

  set setLoginWith(String value) {
    _loginWith = value;
    _formKey.currentState!.reset();
    _phoneController.clear();
    _emailController.clear();
    notifyListeners();
  }

  bool get getIsTermsAccepted => _isTermsAccepted;

  set setIsTermsAccepted(bool value) {
    _isTermsAccepted = value;
    notifyListeners();
  }

  GlobalKey<FormState> get getFormKey => _formKey;

  TextEditingController get getPhoneController => _phoneController;

  TextEditingController get getEmailController => _emailController;

  String get getCountryCode => _countryCode;

  void setCountryCode(String value) {
    _countryCode = value;
    notifyListeners();
  }

  bool validateFormKey() {
    if (_formKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    print('authprovider is disposed');
    _phoneController.dispose();
    _emailController.dispose();
    _formKey.currentState!.reset();
    super.dispose();
  }
}
