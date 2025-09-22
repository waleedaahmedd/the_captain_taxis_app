import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DriverRegistrationViewModel extends ChangeNotifier {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _suburbController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _abnController = TextEditingController();
  final TextEditingController _etagNumberController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _licenseExpiryController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _emergencyContactNumberController = TextEditingController();
  final TextEditingController _emergencyContactEmailController = TextEditingController();
  GlobalKey<FormState>? _formKey;

  // Image picker and document images
  final ImagePicker _imagePicker = ImagePicker();
  File? _identityVerificationImage;
  final Map<String, File?> _documentImages = {
    'driverLicenseFront': null,
    'driverLicenseBack': null,
    'drivingRecord': null,
    'policeCheck': null,
    'passport': null,
    'vevoDetails': null,
    'englishCertificate': null,
  };

  TextEditingController get getFirstNameController => _firstNameController;

  TextEditingController get getLastNameController => _lastNameController;

  TextEditingController get getStreetAddressController => _streetAddressController;

  TextEditingController get getSuburbController => _suburbController;

  TextEditingController get getPostcodeController => _postcodeController;

  TextEditingController get getAbnController => _abnController;

  TextEditingController get getEtagNumberController => _etagNumberController;

  TextEditingController get getLicenseNumberController => _licenseNumberController;

  TextEditingController get getLicenseExpiryController => _licenseExpiryController;

  TextEditingController get getEmergencyContactNameController => _emergencyContactNameController;

  TextEditingController get getEmergencyContactNumberController => _emergencyContactNumberController;

  TextEditingController get getEmergencyContactEmailController => _emergencyContactEmailController;

  GlobalKey<FormState> get getFormKey {
    _formKey ??= GlobalKey<FormState>();
    return _formKey!;
  }

  // Image and document getters
  File? get getIdentityVerificationImage => _identityVerificationImage;
  
  Map<String, File?> get getDocumentImages => Map.from(_documentImages);
  
  File? getDocumentImage(String documentKey) => _documentImages[documentKey];
  
  bool hasDocumentImage(String documentKey) => _documentImages[documentKey] != null;
  
  bool get hasIdentityVerificationImage => _identityVerificationImage != null;
  
  bool get areAllDocumentsUploaded {
    return _documentImages.values.every((image) => image != null) && 
           _identityVerificationImage != null;
  }

  bool validateFormKey() {
    if (_formKey?.currentState?.validate() ?? false) {
      return true;
    } else {
      return false;
    }
  }

  void resetFormKey() {
    _formKey = null;
  }

  // Image handling methods
  Future<void> captureIdentityImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        _identityVerificationImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to capture identity image: $e');
    }
  }

  Future<void> pickDocumentImage(String documentKey, ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (image != null) {
        _documentImages[documentKey] = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to pick document image: $e');
    }
  }

  void removeDocumentImage(String documentKey) {
    _documentImages[documentKey] = null;
    notifyListeners();
  }

  void removeIdentityVerificationImage() {
    _identityVerificationImage = null;
    notifyListeners();
  }

  void clearAllImages() {
    _identityVerificationImage = null;
    _documentImages.updateAll((key, value) => null);
    notifyListeners();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetAddressController.dispose();
    _suburbController.dispose();
    _postcodeController.dispose();
    _abnController.dispose();
    _etagNumberController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactNumberController.dispose();
    _emergencyContactEmailController.dispose();
    super.dispose();
  }
}
