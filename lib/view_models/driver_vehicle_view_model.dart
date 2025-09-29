import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/requests/driver_vehicle_request.dart';
import '../models/responses/driver_vehicle_response.dart';
import '../services/driver_vehicle_service.dart';
import '../services/firebase_service.dart';
import '../utils/image_genrator.dart';
import '../widgets/image_source_bottom_sheet.dart';
import '../models/base_response_model.dart';

class DriverVehicleViewModel extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  final ImageGenerator imageGenerator = ImageGenerator();
  final FirebaseService firebaseService = FirebaseService();

  // Vehicle Information Controllers
  final TextEditingController _taxiPlateController = TextEditingController();
  final TextEditingController _operatorNameController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  // Vehicle Information State
  String _selectedVehicleType = 'sedan';
  String? _frontPlateImage;
  String? _rearPlateImage;
  final Map<String, String?> _requiredDocuments = {
    'registration': null,
    'comprehensiveInsurance': null,
    'ctpInsurance': null,
  };
  final Map<String, String?> _additionalDocuments = {
    'workCover': null,
    'publicLiability': null,
    'safetyInspection': null,
    'cameraInspection': null,
  };

  // Form key management
  GlobalKey<FormState>? _formKey;

  // Getters for controllers
  TextEditingController get getTaxiPlateController => _taxiPlateController;
  TextEditingController get getOperatorNameController => _operatorNameController;
  TextEditingController get getMakeController => _makeController;
  TextEditingController get getModelController => _modelController;
  TextEditingController get getYearController => _yearController;
  TextEditingController get getColorController => _colorController;

  // Vehicle Information State Getters
  String get getSelectedVehicleType => _selectedVehicleType;
  String? get getFrontPlateImage => _frontPlateImage;
  String? get getRearPlateImage => _rearPlateImage;
  Map<String, String?> get getRequiredDocuments => Map.from(_requiredDocuments);
  Map<String, String?> get getAdditionalDocuments => Map.from(_additionalDocuments);

  // Form key management
  GlobalKey<FormState> getFormKeyForStep(int step) {
    if (_formKey == null) {
      _formKey = GlobalKey<FormState>();
    }
    return _formKey!;
  }

  void resetFormKey() {
    if (_formKey != null) {
      _formKey!.currentState?.reset();
      _formKey = null;
    }
  }

  // Vehicle Information Methods
  void setSelectedVehicleType(String type) {
    _selectedVehicleType = type;
    notifyListeners();
  }

  void setFrontPlateImage(String imageUrl) {
    _frontPlateImage = imageUrl;
    notifyListeners();
  }

  void setRearPlateImage(String imageUrl) {
    _rearPlateImage = imageUrl;
    notifyListeners();
  }

  void setVehicleDocumentImage(String documentKey, String imageUrl) {
    if (_requiredDocuments.containsKey(documentKey)) {
      _requiredDocuments[documentKey] = imageUrl;
    } else if (_additionalDocuments.containsKey(documentKey)) {
      _additionalDocuments[documentKey] = imageUrl;
    }
    notifyListeners();
  }

  // Document checking methods
  bool hasRequiredDocument(String documentKey) => _requiredDocuments[documentKey] != null;
  bool hasAdditionalDocument(String documentKey) => _additionalDocuments[documentKey] != null;
  bool hasPlateImage(bool isFront) => isFront ? _frontPlateImage != null : _rearPlateImage != null;
  
  // Document image getters
  String? getRequiredDocumentImage(String documentKey) => _requiredDocuments[documentKey];
  String? getAdditionalDocumentImage(String documentKey) => _additionalDocuments[documentKey];
  String? getDocumentImage(String documentKey) {
    if (_requiredDocuments.containsKey(documentKey)) {
      return _requiredDocuments[documentKey];
    } else if (_additionalDocuments.containsKey(documentKey)) {
      return _additionalDocuments[documentKey];
    }
    return null;
  }

  // Image capture methods
  // Plate image capture with Firebase upload
  Future<void> capturePlateImageWithGenerator(bool isFront) async {
    try {
      EasyLoading.show(status: 'Capturing plate image...');
      
      final File imageFile = await imageGenerator.createImageFile(fromCamera: true);
      
      EasyLoading.show(status: 'Uploading plate image...');
      
      final String imageUrl = await firebaseService.upLoadImageFile(
        mFileImage: imageFile,
        fileName: '${isFront ? 'front' : 'rear'}_plate_${DateTime.now().millisecondsSinceEpoch}',
        folderName: 'Vehicle Plates',
      );
      
      if (isFront) {
        setFrontPlateImage(imageUrl);
      } else {
        setRearPlateImage(imageUrl);
      }
      
      EasyLoading.showSuccess('${isFront ? 'Front' : 'Rear'} plate image captured successfully!');
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  // Document image upload with Firebase
  Future<void> pickVehicleDocumentWithGenerator(String documentKey) async {
    try {
      await ImageSourceBottomSheet.show(
        title: 'Select Image Source',
        subtitle: 'Choose how you want to add the image',
        onImageSelected: (source) async {
          try {
            EasyLoading.show(status: 'Capturing document...');
            
            final File imageFile = await imageGenerator.createImageFile(fromCamera: source == ImageSource.camera);
            
            EasyLoading.show(status: 'Uploading document...');
            
            final String imageUrl = await firebaseService.upLoadImageFile(
              mFileImage: imageFile,
              fileName: '${documentKey}_${DateTime.now().millisecondsSinceEpoch}',
              folderName: 'Vehicle Documents',
            );
            
            setVehicleDocumentImage(documentKey, imageUrl);
            EasyLoading.showSuccess('Document uploaded successfully!');
          } catch (e) {
            EasyLoading.showError(e.toString());
          }
        },
      );
    } catch (e) {
      debugPrint('Vehicle document pick error: $e');
      throw Exception('Failed to upload document. Please check permissions and try again.');
    }
  }

  Future<void> pickVehicleDocumentImage(String documentKey, ImageSource source) async {
    try {
      EasyLoading.show(status: 'Capturing document...');
      
      final File imageFile = await imageGenerator.createImageFile(fromCamera: source == ImageSource.camera);
      
      EasyLoading.show(status: 'Uploading document...');
      
      final String imageUrl = await firebaseService.upLoadImageFile(
        mFileImage: imageFile,
        fileName: '${documentKey}_${DateTime.now().millisecondsSinceEpoch}',
        folderName: 'Vehicle Documents',
      );
      
      if (_requiredDocuments.containsKey(documentKey)) {
        _requiredDocuments[documentKey] = imageUrl;
      } else {
        _additionalDocuments[documentKey] = imageUrl;
      }
      notifyListeners();
      
      EasyLoading.showSuccess('Document uploaded successfully!');
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  // Form validation
  bool validateForm() {
    if (_formKey?.currentState?.validate() == true) {
      return true;
    } else {
      return false;
    }
  }

  // Get all vehicle information as a map
  Map<String, dynamic> getVehicleInfo() {
    return {
      'taxiPlate': _taxiPlateController.text.trim(),
      'operatorName': _operatorNameController.text.trim(),
      'make': _makeController.text.trim(),
      'model': _modelController.text.trim(),
      'year': _yearController.text.trim(),
      'color': _colorController.text.trim(),
      'selectedVehicleType': _selectedVehicleType,
      'frontPlateImage': _frontPlateImage,
      'rearPlateImage': _rearPlateImage,
      'requiredDocuments': _requiredDocuments,
      'additionalDocuments': _additionalDocuments,
    };
  }

  // Set vehicle information from a map
  void setVehicleInfo(Map<String, dynamic> vehicleInfo) {
    _taxiPlateController.text = vehicleInfo['taxiPlate'] ?? '';
    _operatorNameController.text = vehicleInfo['operatorName'] ?? '';
    _makeController.text = vehicleInfo['make'] ?? '';
    _modelController.text = vehicleInfo['model'] ?? '';
    _yearController.text = vehicleInfo['year'] ?? '';
    _colorController.text = vehicleInfo['color'] ?? '';
    _selectedVehicleType = vehicleInfo['selectedVehicleType'] ?? 'sedan';
    
    if (vehicleInfo['frontPlateImage'] != null && vehicleInfo['frontPlateImage'].isNotEmpty) {
      _frontPlateImage = vehicleInfo['frontPlateImage'];
    }
    if (vehicleInfo['rearPlateImage'] != null && vehicleInfo['rearPlateImage'].isNotEmpty) {
      _rearPlateImage = vehicleInfo['rearPlateImage'];
    }
    
    if (vehicleInfo['requiredDocuments'] != null) {
      final requiredDocs = Map<String, String>.from(vehicleInfo['requiredDocuments']);
      requiredDocs.forEach((key, value) {
        if (value.isNotEmpty) {
          _requiredDocuments[key] = value;
        }
      });
    }
    
    if (vehicleInfo['additionalDocuments'] != null) {
      final additionalDocs = Map<String, String>.from(vehicleInfo['additionalDocuments']);
      additionalDocs.forEach((key, value) {
        if (value.isNotEmpty) {
          _additionalDocuments[key] = value;
        }
      });
    }
    
    notifyListeners();
  }

  // Check if all required fields are filled
  bool get isFormComplete {
    final vehicleInfo = getVehicleInfo();
    return vehicleInfo['taxiPlate'].isNotEmpty &&
           vehicleInfo['operatorName'].isNotEmpty &&
           vehicleInfo['make'].isNotEmpty &&
           vehicleInfo['model'].isNotEmpty &&
           vehicleInfo['year'].isNotEmpty &&
           vehicleInfo['color'].isNotEmpty;
  }

  // Clear all controllers and images
  void clearAllData() {
    _taxiPlateController.clear();
    _operatorNameController.clear();
    _makeController.clear();
    _modelController.clear();
    _yearController.clear();
    _colorController.clear();
    _selectedVehicleType = 'sedan';
    _frontPlateImage = null;
    _rearPlateImage = null;
    _requiredDocuments.updateAll((key, value) => null);
    _additionalDocuments.updateAll((key, value) => null);
    notifyListeners();
  }

  // Service instance for API calls
  final DriverVehicleService _service = DriverVehicleService();

  // Create DriverVehicleRequest from current data
  DriverVehicleRequest createRequest() {
    return DriverVehicleRequest(
      taxiPlate: _taxiPlateController.text.trim(),
      operatorName: _operatorNameController.text.trim(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: _yearController.text.trim(),
      color: _colorController.text.trim(),
      selectedVehicleType: _selectedVehicleType,
      frontPlateImage: _frontPlateImage,
      rearPlateImage: _rearPlateImage,
      requiredDocuments: _requiredDocuments,
      additionalDocuments: _additionalDocuments,
    );
  }

  // Set data from DriverVehicleRequest
  void setFromRequest(DriverVehicleRequest request) {
    _taxiPlateController.text = request.taxiPlate ?? '';
    _operatorNameController.text = request.operatorName ?? '';
    _makeController.text = request.make ?? '';
    _modelController.text = request.model ?? '';
    _yearController.text = request.year ?? '';
    _colorController.text = request.color ?? '';
    _selectedVehicleType = request.selectedVehicleType ?? 'sedan';
    
    if (request.frontPlateImage != null && request.frontPlateImage!.isNotEmpty) {
      _frontPlateImage = request.frontPlateImage;
    }
    if (request.rearPlateImage != null && request.rearPlateImage!.isNotEmpty) {
      _rearPlateImage = request.rearPlateImage;
    }
    
    if (request.requiredDocuments != null) {
      request.requiredDocuments!.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          _requiredDocuments[key] = value;
        }
      });
    }
    
    if (request.additionalDocuments != null) {
      request.additionalDocuments!.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          _additionalDocuments[key] = value;
        }
      });
    }
    
    notifyListeners();
  }

  // Submit vehicle information to API
  Future<BaseResponseModel> submitVehicleInfo() async {
    final request = createRequest();
    return await _service.submitDriverVehicle(request);
  }

  // Update vehicle information via API
  Future<BaseResponseModel> updateVehicleInfo(String driverId) async {
    final request = createRequest();
    return await _service.updateDriverVehicle(request, driverId);
  }

  // Load vehicle information from API
  Future<DriverVehicleResponse> loadVehicleInfo(String driverId) async {
    final response = await _service.getDriverVehicle(driverId);
    
    if (response.isSuccess == true && response.driverVehicleModel != null) {
      try {
        setFromRequest(DriverVehicleRequest(
          taxiPlate: response.driverVehicleModel!.taxiPlate,
          operatorName: response.driverVehicleModel!.operatorName,
          make: response.driverVehicleModel!.make,
          model: response.driverVehicleModel!.model,
          year: response.driverVehicleModel!.year,
          color: response.driverVehicleModel!.color,
          selectedVehicleType: response.driverVehicleModel!.selectedVehicleType,
          frontPlateImage: response.driverVehicleModel!.frontPlateImage,
          rearPlateImage: response.driverVehicleModel!.rearPlateImage,
          requiredDocuments: response.driverVehicleModel!.requiredDocuments,
          additionalDocuments: response.driverVehicleModel!.additionalDocuments,
        ));
      } catch (e) {
        // Handle parsing error if needed
      }
    }
    
    return response;
  }

  @override
  void dispose() {
    _taxiPlateController.dispose();
    _operatorNameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}
