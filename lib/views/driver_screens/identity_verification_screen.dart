import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/custom_buttons.dart';
import '../../utils/custom_font_style.dart';
import '../../view_models/driver_registration_view_model.dart';
import '../../widgets/custom_progress_indicator.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final frontCamera = _cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameraController == null) return;

    setState(() {
      _isCameraInitialized = false;
    });

    await _cameraController!.dispose();

    final newCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == (_isFrontCamera ? CameraLensDirection.back : CameraLensDirection.front),
      orElse: () => _cameras.first,
    );

    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    setState(() {
      _isCameraInitialized = true;
      _isFrontCamera = !_isFrontCamera;
    });
  }

  Future<void> _captureImage(DriverRegistrationViewModel viewModel) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();

      // Process the captured image
      final success = await viewModel.captureIdentityImageWithGenerator(File(image.path));

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Image capture error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CustomColors.primaryColor),
              ),
              SizedBox(height: 16.h),
              Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: CustomColors.whiteColor,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildFaceCutoutOverlay() {
    return CustomPaint(
      painter: FaceCutoutPainter(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Face icon in the center of the cutout
              Icon(
                Iconsax.user,
                size: 48.sp,
                color: CustomColors.primaryColor.withValues(alpha: 0.8),
              ),
              SizedBox(height: 12.h),
              Text(
                'Align your face within the oval frame',
                style: TextStyle(
                  color: CustomColors.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Make sure your face is clearly visible',
                style: TextStyle(
                  color: CustomColors.whiteColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.blackColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left_2,
            color: CustomColors.whiteColor,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Face Verification',
          style: TextStyle(
            color: CustomColors.whiteColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.camera,
              color: CustomColors.whiteColor,
              size: 24.sp,
            ),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Consumer<DriverRegistrationViewModel>(
        builder: (context, viewModel, child) {
          return SizedBox.expand(
            child: Stack(
              children: [
                // Camera Preview - Full Screen
                Positioned.fill(
                  child: _buildCameraPreview(),
                ),

                // Face Cutout Overlay
                Positioned.fill(
                  child: _buildFaceCutoutOverlay(),
                ),

                // Top Instructions
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: CustomColors.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.info_circle,
                                    size: 16.sp,
                                    color: CustomColors.primaryColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Verification Tips',
                                    style: TextStyle(
                                      color: CustomColors.primaryColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '• Ensure good lighting\n• Look directly at the camera\n• Keep your face centered\n• Remove glasses if possible\n• Maintain a neutral expression',
                                style: TextStyle(
                                  color: CustomColors.whiteColor,
                                  fontSize: 12.sp,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Upload Progress (when uploading)
                            if (viewModel.getUpLoadingProfileImage > 0)
                              Container(
                                margin: EdgeInsets.only(bottom: 16.h),
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: CustomColors.primaryColor,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Iconsax.cloud_plus,
                                          size: 20.sp,
                                          color: CustomColors.primaryColor,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Uploading Verification...',
                                          style: TextStyle(
                                            color: CustomColors.whiteColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    LinearProgressIndicator(
                                      value: viewModel.getUpLoadingProfileImage,
                                      backgroundColor: Colors.grey[800],
                                      valueColor: AlwaysStoppedAnimation<Color>(CustomColors.primaryColor),
                                      minHeight: 6.h,
                                      borderRadius: BorderRadius.circular(3.r),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      '${(viewModel.getUpLoadingProfileImage * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: CustomColors.whiteColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Capture Button
                            Container(
                              width: 80.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CustomColors.whiteColor,
                                  width: 4,
                                ),
                              ),
                              child: IconButton(
                                icon: Container(
                                  width: 60.w,
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CustomColors.whiteColor,
                                  ),
                                ),
                                onPressed: () => _captureImage(viewModel),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FaceCutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radiusX = size.width * 0.35; // Horizontal radius for oval
    final double radiusY = size.height * 0.25; // Vertical radius for oval
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Create oval path for the face cutout
    final Path ovalPath = Path()
      ..addOval(Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      ));

    // Draw dark overlay with oval cutout
    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);
    
    // Create a path that covers the entire screen
    final Path fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create the cutout by subtracting the oval from the full screen
    final Path cutoutPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      ovalPath,
    );

    // Draw the dark overlay with cutout
    canvas.drawPath(cutoutPath, overlayPaint);

    // Draw border around the oval cutout
    final Paint borderPaint = Paint()
      ..color = CustomColors.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      borderPaint,
    );

    // Draw corner guides for better alignment
    final double guideLength = radiusX * 0.3;
    final double offsetX = radiusX * 0.8;
    final double offsetY = radiusY * 0.8;

    _drawCornerGuide(canvas, center.dx - offsetX, center.dy - offsetY, guideLength, true, true);
    _drawCornerGuide(canvas, center.dx + offsetX, center.dy - offsetY, guideLength, false, true);
    _drawCornerGuide(canvas, center.dx - offsetX, center.dy + offsetY, guideLength, true, false);
    _drawCornerGuide(canvas, center.dx + offsetX, center.dy + offsetY, guideLength, false, false);
  }

  void _drawCornerGuide(Canvas canvas, double x, double y, double length, bool isLeft, bool isTop) {
    final Paint paint = Paint()
      ..color = CustomColors.primaryColor
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}