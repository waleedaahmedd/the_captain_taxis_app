import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' as mlkit;

import '../../utils/custom_colors.dart';
import '../../view_models/driver_vehicle_view_model.dart';


class VehicleNumberPlateScreen extends StatefulWidget {
  final bool isFrontPlate;
  
  const VehicleNumberPlateScreen({
    super.key,
    required this.isFrontPlate,
  });

  @override
  State<VehicleNumberPlateScreen> createState() => _VehicleNumberPlateScreenState();
}

class _VehicleNumberPlateScreenState extends State<VehicleNumberPlateScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isBackCamera = true;
  bool _cameraInitializationFailed = false;
  
  // Text recognition variables
  late mlkit.TextRecognizer _textRecognizer;
  bool _isTextDetected = false;
  bool _isValidNumberPlate = false;
  String _detectedText = '';
  String _numberPlateMessage = 'Position the number plate in the frame';
  int _frameCount = 0;
  String? _extractedNumberPlate;

  @override
  void initState() {
    super.initState();
    _initializeTextRecognizer();
    _initializeCamera();
  }

  void _initializeTextRecognizer() {
    try {
      _textRecognizer = mlkit.TextRecognizer();
      debugPrint('Text recognizer initialized successfully');
    } catch (e) {
      debugPrint('Error initializing text recognizer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize text recognition: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Use back camera for better number plate visibility
        final backCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
        
        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
          
          // Start image stream for text recognition
          try {
            _cameraController!.startImageStream(_processImageForTextRecognition);
          } catch (e) {
            debugPrint('Error starting image stream: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to start camera stream: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _cameraInitializationFailed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize camera: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _cameraInitializationFailed = false;
                });
                _initializeCamera();
              },
            ),
          ),
        );
      }
    }
  }

  void _processImageForTextRecognition(CameraImage cameraImage) async {
    if (_frameCount % 15 == 0) { // Process every 15th frame for better performance
      try {
        final mlkit.InputImage inputImage = _inputImageFromCameraImage(cameraImage);
        final mlkit.RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
        
        if (mounted) {
          final String detectedText = recognizedText.text.trim();
          final bool isTextDetected = detectedText.isNotEmpty;
          final String? extractedNumberPlate = isTextDetected ? _extractNumberPlate(detectedText) : null;
          final bool isValidNumberPlate = extractedNumberPlate != null;
          
          // Only update state if values have changed to avoid unnecessary rebuilds
          if (_detectedText != detectedText || 
              _isTextDetected != isTextDetected || 
              _extractedNumberPlate != extractedNumberPlate || 
              _isValidNumberPlate != isValidNumberPlate) {
            setState(() {
              _detectedText = detectedText;
              _isTextDetected = isTextDetected;
              _extractedNumberPlate = extractedNumberPlate;
              _isValidNumberPlate = isValidNumberPlate;
              _numberPlateMessage = isValidNumberPlate 
                  ? 'Number plate detected: $extractedNumberPlate'
                  : isTextDetected 
                      ? 'Text detected but not a valid number plate'
                      : 'Position the number plate in the frame';
            });
          }
        }
      } catch (e) {
        debugPrint('Error processing image for text recognition: $e');
        // Don't update UI on error to avoid flickering
      }
    }
    _frameCount++;
  }

  mlkit.InputImage _inputImageFromCameraImage(CameraImage cameraImage) {
    if (_cameras.isEmpty) {
      throw Exception('No cameras available');
    }
    
    final CameraDescription camera = _cameras.first;
    final sensorOrientation = camera.sensorOrientation;
    
    mlkit.InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = mlkit.InputImageRotation.rotation90deg;
    } else if (Platform.isAndroid) {
      var rotationCompensation = sensorOrientation;
      rotation = mlkit.InputImageRotation.values.firstWhere(
        (element) => element.rawValue == rotationCompensation,
        orElse: () => mlkit.InputImageRotation.rotation0deg,
      );
    }
    
    final mlkit.InputImageFormat format = mlkit.InputImageFormat.nv21;
    
    final Size imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );
    
    final plane = cameraImage.planes.first;
    final data = plane.bytes;
    final bytesPerRow = plane.bytesPerRow;
    
    final metadata = mlkit.InputImageMetadata(
      size: imageSize,
      rotation: rotation ?? mlkit.InputImageRotation.rotation0deg,
      format: format,
      bytesPerRow: bytesPerRow,
    );
    
    return mlkit.InputImage.fromBytes(
      bytes: data,
      metadata: metadata,
    );
  }

  String? _extractNumberPlate(String text) {
    if (text.trim().isEmpty) return null;
    
    // Remove whitespace and convert to uppercase
    String cleanText = text.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    
    // Remove common OCR artifacts
    cleanText = cleanText.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (cleanText.length < 4 || cleanText.length > 8) return null;
    
    // Common number plate patterns (adjust based on your region)
    List<RegExp> patterns = [
      // Australian format: ABC-123 or ABC123
      RegExp(r'^[A-Z]{3}[-]?[0-9]{3}$'),
      // US format: ABC-1234 or ABC1234
      RegExp(r'^[A-Z]{3}[-]?[0-9]{4}$'),
      // Generic format: 3 letters followed by 3-4 numbers
      RegExp(r'^[A-Z]{3}[-]?[0-9]{3,4}$'),
      // Format with spaces: ABC 123 or ABC 1234
      RegExp(r'^[A-Z]{3}\s[0-9]{3,4}$'),
      // More flexible pattern: 2-4 letters followed by 2-4 numbers
      RegExp(r'^[A-Z]{2,4}[-]?[0-9]{2,4}$'),
      // Pure alphanumeric: ABC123, ABC1234, etc.
      RegExp(r'^[A-Z]{2,4}[0-9]{2,4}$'),
    ];
    
    for (RegExp pattern in patterns) {
      if (pattern.hasMatch(cleanText)) {
        return cleanText;
      }
    }
    
    // If no pattern matches, try to extract any alphanumeric sequence
    RegExp alphanumeric = RegExp(r'[A-Z0-9]{5,8}');
    Match? match = alphanumeric.firstMatch(cleanText);
    if (match != null) {
      String extracted = match.group(0)!;
      // Only return if it has both letters and numbers and reasonable length
      if (RegExp(r'[A-Z]').hasMatch(extracted) && 
          RegExp(r'[0-9]').hasMatch(extracted) &&
          extracted.length >= 5) {
        return extracted;
      }
    }
    
    return null;
  }

  Future<void> _captureNumberPlate() async {
    if (_isValidNumberPlate && _extractedNumberPlate != null) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
        
        final DriverVehicleViewModel viewModel = Provider.of<DriverVehicleViewModel>(context, listen: false);
        await viewModel.capturePlateImageWithGenerator(widget.isFrontPlate);
        
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.pop(context, _extractedNumberPlate);
        }
      } catch (e) {
        debugPrint('Error capturing number plate: $e');
        if (mounted) {
          Navigator.pop(context); // Close loading dialog if open
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to capture number plate: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.isFrontPlate ? 'Front' : 'Rear'} Number Plate',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            // Loading state or error state
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_cameraInitializationFailed) ...[
                        Icon(
                          Iconsax.camera_slash,
                          color: Colors.red,
                          size: 64.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Camera initialization failed',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Please check camera permissions and try again',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _cameraInitializationFailed = false;
                            });
                            _initializeCamera();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Retry'),
                        ),
                      ] else ...[
                        CircularProgressIndicator(
                          color: CustomColors.primaryColor,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Initializing camera...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          
          // Number plate detection overlay
          if (_isCameraInitialized)
            _buildNumberPlateOverlay(),
          
          // Instructions at the top
          Positioned(
            top: 20.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    'Position the ${widget.isFrontPlate ? 'front' : 'rear'} number plate in the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _numberPlateMessage,
                    style: TextStyle(
                      color: _isValidNumberPlate ? Colors.green : Colors.orange,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Capture button at the bottom
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isValidNumberPlate ? _captureNumberPlate : null,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isValidNumberPlate 
                        ? CustomColors.primaryColor 
                        : Colors.grey.withOpacity(0.5),
                    border: Border.all(
                      color: Colors.white,
                      width: 3.w,
                    ),
                  ),
                  child: Icon(
                    _isValidNumberPlate ? Iconsax.camera : Iconsax.camera_slash,
                    color: Colors.white,
                    size: 32.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPlateOverlay() {
    return CustomPaint(
      painter: NumberPlateOverlayPainter(
        isDetected: _isTextDetected,
        isValid: _isValidNumberPlate,
      ),
      size: Size.infinite,
    );
  }
}

class NumberPlateOverlayPainter extends CustomPainter {
  final bool isDetected;
  final bool isValid;

  NumberPlateOverlayPainter({
    required this.isDetected,
    required this.isValid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width * 0.8;
    final double height = size.height * 0.2;
    final double left = (size.width - width) / 2;
    final double top = (size.height - height) / 2;

    // Create rectangular path for the number plate cutout
    final Path rectPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height),
        const Radius.circular(12),
      ));

    // Draw dark overlay with rectangular cutout
    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);

    // Create a path that covers the entire screen
    final Path fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create the cutout by subtracting the rectangle from the full screen
    final Path cutoutPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      rectPath,
    );

    // Draw the dark overlay with cutout
    canvas.drawPath(cutoutPath, overlayPaint);

    // Draw border around the rectangular cutout
    final Paint borderPaint = Paint()
      ..color = isValid ? Colors.green : (isDetected ? Colors.orange : CustomColors.primaryColor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Draw corner guides for better alignment
    final double guideLength = width * 0.1;
    _drawCornerGuide(canvas, left, top, guideLength, true, true);
    _drawCornerGuide(canvas, left + width, top, guideLength, false, true);
    _drawCornerGuide(canvas, left, top + height, guideLength, true, false);
    _drawCornerGuide(canvas, left + width, top + height, guideLength, false, false);
  }

  void _drawCornerGuide(Canvas canvas, double x, double y, double length, bool isLeft, bool isTop) {
    final Paint paint = Paint()
      ..color = isValid ? Colors.green : (isDetected ? Colors.orange : CustomColors.primaryColor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Horizontal line
    canvas.drawLine(
      Offset(x + (isLeft ? -length : 0), y),
      Offset(x + (isLeft ? 0 : length), y),
      paint,
    );
    // Vertical line
    canvas.drawLine(
      Offset(x, y + (isTop ? -length : 0)),
      Offset(x, y + (isTop ? 0 : length)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
