import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_font_style.dart';
import '../../../utils/image_genrator.dart';
import '../../../view_models/driver_vehicle_view_model.dart';
import '../../../widgets/image_source_bottom_sheet.dart';
import '../../view_models/driver_documents_view_model.dart';
import '../../widgets/custom_app_bar_widget.dart';

class DriverVehicleScreen extends StatelessWidget {
  const DriverVehicleScreen({super.key});

  static Widget withAppBar({Key? key}) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: ''),
      body: ChangeNotifierProvider(
        create: (BuildContext context) => DriverVehicleViewModel(),
        child: DriverVehicleScreen(key: key),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverVehicleViewModel>(
      builder: (context, viewModel, child) {
        return Form(
          key: viewModel.getFormKeyForStep(3),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 20.h),
              child: AnimationLimiter(
                child: Column(
                  children: [
                    black24w600(data: 'Vehicle Information'),
                    grey12(data: 'Complete your vehicle details and documents'),
                    SizedBox(height: 20.h),

                    // All Sections in One Column (animated)
                    Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (widget) => FlipAnimation(
                          duration: Duration(seconds: 1),
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          _buildVehicleInformationSection(viewModel),
                          SizedBox(height: 24.h),
                          _buildLicensePlateSection(viewModel),
                          SizedBox(height: 24.h),
                          _buildRequiredDocumentsSection(context, viewModel),
                          SizedBox(height: 24.h),
                          _buildAdditionalDocumentsSection(context, viewModel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Section 1: Vehicle Information
  Widget _buildVehicleInformationSection(DriverVehicleViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[9],
        color: CustomColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: CustomColors.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.car, color: CustomColors.primaryColor, size: 24.sp),
              SizedBox(width: 12.w),
              black18w500(data: 'Vehicle Information'),
            ],
          ),
          SizedBox(height: 8.h),
          grey12(data: 'Enter your vehicle details'),
          SizedBox(height: 20.h),
          
          // Taxi Plate Number and Operator Name
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Taxi Plate Number',
                  'e.g., TAXI-123',
                  viewModel.getTaxiPlateController,
                  icon: Iconsax.card,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInputField(
                  'Operator Name',
                  'e.g., John Smith',
                  viewModel.getOperatorNameController,
                  icon: Iconsax.user,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Make and Model
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Make',
                  'e.g., Toyota',
                  viewModel.getMakeController,
                  icon: Iconsax.car,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInputField(
                  'Model',
                  'e.g., Camry',
                  viewModel.getModelController,
                  icon: Iconsax.car,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Year and Color
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Year',
                  'e.g., 2020',
                  viewModel.getYearController,
                  keyboardType: TextInputType.number,
                  icon: Iconsax.calendar,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInputField(
                  'Color',
                  'e.g., White',
                  viewModel.getColorController,
                  icon: Iconsax.colorfilter,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Vehicle Type Selection
          _buildVehicleTypeSelection(viewModel),
        ],
      ),
    );
  }

  // Section 2: License Plate Recognition
  Widget _buildLicensePlateSection(DriverVehicleViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[9],
        color: CustomColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: CustomColors.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.scan, color: CustomColors.primaryColor, size: 24.sp),
              SizedBox(width: 12.w),
              black18w500(data: 'License Plate Recognition'),
            ],
          ),
          SizedBox(height: 8.h),
          grey12(data: 'Capture front and rear number plate images'),
          SizedBox(height: 20.h),
          
          // Front Plate
          _buildPlateCapture('Front Number Plate', viewModel.getFrontPlateImage, () => _capturePlateImage(true, viewModel)),
          SizedBox(height: 16.h),
          
          // Rear Plate
          _buildPlateCapture('Rear Number Plate', viewModel.getRearPlateImage, () => _capturePlateImage(false, viewModel)),
        ],
      ),
    );
  }

  // Section 3: Required Documents
  Widget _buildRequiredDocumentsSection(BuildContext context, DriverVehicleViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[9],
        color: CustomColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: CustomColors.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.document_text, color: CustomColors.primaryColor, size: 24.sp),
              SizedBox(width: 12.w),
              black18w500(data: 'Required Documents'),
            ],
          ),
          SizedBox(height: 8.h),
          grey12(data: 'Upload required vehicle documents'),
          SizedBox(height: 20.h),
          
          _buildDocumentItem(context, 'Registration', 'registration', Iconsax.document, viewModel),
          SizedBox(height: 16.h),
          _buildDocumentItem(context, 'Comprehensive Insurance', 'comprehensiveInsurance', Iconsax.shield_tick, viewModel),
          SizedBox(height: 16.h),
          _buildDocumentItem(context, 'CTP Insurance', 'ctpInsurance', Iconsax.shield_tick, viewModel),
        ],
      ),
    );
  }

  // Section 4: Additional Documents
  Widget _buildAdditionalDocumentsSection(BuildContext context, DriverVehicleViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[9],
        color: CustomColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: CustomColors.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.folder, color: CustomColors.primaryColor, size: 24.sp),
              SizedBox(width: 12.w),
              black18w500(data: 'Additional Documents'),
            ],
          ),
          SizedBox(height: 8.h),
          grey12(data: 'Upload additional required documents'),
          SizedBox(height: 20.h),
          
          _buildDocumentItem(context, 'Work Cover', 'workCover', Iconsax.verify, viewModel),
          SizedBox(height: 16.h),
          _buildDocumentItem(context, 'Public Liability', 'publicLiability', Iconsax.shield_tick, viewModel),
          SizedBox(height: 16.h),
          _buildDocumentItem(context, 'Safety Inspection', 'safetyInspection', Iconsax.scan, viewModel),
          SizedBox(height: 16.h),
          _buildDocumentItem(context, 'Camera Inspection', 'cameraInspection', Iconsax.camera, viewModel),
        ],
      ),
    );
  }

  // Helper Methods
  Widget _buildInputField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[3],
        color: CustomColors.whiteColor,
        borderRadius: BorderRadius.all(Radius.circular(15.r)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
          prefixIcon: Icon(icon),
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _buildVehicleTypeSelection(DriverVehicleViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        black14w500(data: 'Vehicle Type'),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildVehicleTypeOption('Sedan', Iconsax.car, 'sedan', viewModel)),
            SizedBox(width: 8.w),
            Expanded(child: _buildVehicleTypeOption('SUV', Iconsax.car, 'suv', viewModel)),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(child: _buildVehicleTypeOption('Hatchback', Iconsax.car, 'hatchback', viewModel)),
            SizedBox(width: 8.w),
            Expanded(child: _buildVehicleTypeOption('Van', Iconsax.truck, 'van', viewModel)),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleTypeOption(String title, IconData icon, String value, DriverVehicleViewModel viewModel) {
    final isSelected = viewModel.getSelectedVehicleType == value;
    return GestureDetector(
      onTap: () => viewModel.setSelectedVehicleType(value),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.primaryColor.withValues(alpha: 0.1) : CustomColors.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? CustomColors.primaryColor : CustomColors.primaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? CustomColors.primaryColor : CustomColors.blackColor.withValues(alpha: 0.6), size: 24.w),
            SizedBox(height: 4.h),
            black14w500(data: title),
          ],
        ),
      ),
    );
  }

  Widget _buildPlateCapture(String title, String? imageUrl, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        black14w500(data: title),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120.h,
            decoration: BoxDecoration(
              color: imageUrl != null ? Colors.transparent : CustomColors.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: CustomColors.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: CustomColors.primaryColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Iconsax.image,
                            color: Colors.grey[400],
                            size: 40.sp,
                          ),
                        );
                      },
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.camera, size: 32.sp, color: CustomColors.primaryColor.withValues(alpha: 0.6)),
                      SizedBox(height: 8.h),
                      grey12(data: 'Tap to capture', centre: true),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(BuildContext context, String title, String documentKey, IconData icon, DriverVehicleViewModel viewModel) {
    final hasImage = viewModel.hasRequiredDocument(documentKey) || viewModel.hasAdditionalDocument(documentKey);
    final documentImage = viewModel.getDocumentImage(documentKey);
    
    return GestureDetector(
      onTap: () => _pickVehicleDocument(context, documentKey, viewModel),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          boxShadow: kElevationToShadow[3],
          color: CustomColors.whiteColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: hasImage ? CustomColors.primaryColor : CustomColors.primaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: hasImage ? CustomColors.primaryColor : CustomColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    hasImage ? Iconsax.tick_circle : icon,
                    color: hasImage ? CustomColors.whiteColor : CustomColors.primaryColor,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      black14w500(data: title),
                      SizedBox(height: 4.h),
                      grey12(data: hasImage ? 'Document uploaded' : 'Tap to upload'),
                    ],
                  ),
                ),
                Icon(
                  hasImage ? Iconsax.tick_circle : Iconsax.arrow_right_3,
                  color: hasImage ? CustomColors.primaryColor : CustomColors.blackColor.withValues(alpha: 0.4),
                  size: 20.w,
                ),
              ],
            ),
            
            // Show document image preview if available
            if (hasImage && documentImage != null) ...[
              SizedBox(height: 16.h),
              Container(
                height: 120.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: CustomColors.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    documentImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: CustomColors.primaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Iconsax.image,
                          color: Colors.grey[400],
                          size: 40.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Capture plate image using ImageGenerator with Firebase upload
  Future<void> _capturePlateImage(bool isFront, DriverVehicleViewModel viewModel) async {
    try {
      await viewModel.capturePlateImageWithGenerator(isFront);
    } catch (e) {
      debugPrint('Plate capture error: $e');
      _showErrorMessage('Failed to capture plate image. Please check camera permissions and try again.');
    }
  }

  // Pick vehicle document using ImageGenerator with Firebase upload
  Future<void> _pickVehicleDocument(BuildContext context, String documentKey, DriverVehicleViewModel viewModel) async {
    try {
      await viewModel.pickVehicleDocumentWithGenerator(documentKey);
    } catch (e) {
      debugPrint('Vehicle document pick error: $e');
      _showErrorMessage('Failed to upload document. Please check permissions and try again.');
    }
  }

  void _showSuccessMessage(String message) {
    // Note: This would need to be called from a StatefulWidget context
    // For now, we'll use debugPrint
    debugPrint('Success: $message');
  }

  void _showErrorMessage(String message) {
    // Note: This would need to be called from a StatefulWidget context
    // For now, we'll use debugPrint
    debugPrint('Error: $message');
  }
}