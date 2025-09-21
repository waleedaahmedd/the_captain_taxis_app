import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/custom_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.whiteColor,
      appBar: _buildCustomAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              
              // Welcome Section
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontFamily: 'CircularStd',
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.blackColor,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              Text(
                'Here\'s what\'s happening today',
                style: TextStyle(
                  fontFamily: 'CircularStd',
                  fontSize: 16.sp,
                  color: CustomColors.blackColor.withValues(alpha: 0.6),
                ),
              ),
              
              SizedBox(height: 30.h),
              
              // Quick Actions Card
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
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
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontFamily: 'CircularStd',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.blackColor,
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    

                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Recent Activity Card
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
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
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontFamily: 'CircularStd',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.blackColor,
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    

                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }





  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    // Calculate the height based on the content to avoid overflow
    final double topPadding = MediaQuery.of(context).padding.top;
    final double height = topPadding + 80; // Adjusted height to prevent overflow

    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          padding: EdgeInsets.only(
            top: topPadding + 10,
            left: 20,
            right: 20,
            bottom: 10,
          ),
          child: Row(
            children: [
              // Customer Profile Section
              Expanded(
                child: Row(
                  children: [
                    // Customer Image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 24,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Customer Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Good morning!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Notification Bell Icon
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      // Notification Badge
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    // Handle notification tap
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notifications'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}