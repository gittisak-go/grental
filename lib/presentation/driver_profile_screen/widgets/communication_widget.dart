import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommunicationWidget extends StatelessWidget {
  final Map<String, dynamic> driverData;

  const CommunicationWidget({
    super.key,
    required this.driverData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Communication',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 3.h),

          // Communication buttons
          Row(
            children: [
              // Call button
              Expanded(
                child: _buildCommunicationButton(
                  context,
                  theme,
                  'phone',
                  'Call Driver',
                  AppTheme.successLight,
                  () => _handleCall(context),
                ),
              ),

              SizedBox(width: 3.w),

              // Message button
              Expanded(
                child: _buildCommunicationButton(
                  context,
                  theme,
                  'message',
                  'Send Message',
                  AppTheme.lightTheme.colorScheme.primary,
                  () => _handleMessage(context),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Emergency contact info
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.errorLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.errorLight.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'emergency',
                  color: AppTheme.errorLight,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Contact',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorLight,
                        ),
                      ),
                      Text(
                        'Tap to report safety concerns',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _handleEmergency(context),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'warning',
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationButton(
    BuildContext context,
    ThemeData theme,
    String iconName,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleCall(BuildContext context) {
    // Simulate call functionality
    Fluttertoast.showToast(
      msg: "Calling ${driverData["name"]}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successLight,
      textColor: Colors.white,
    );
  }

  void _handleMessage(BuildContext context) {
    // Show message options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMessageBottomSheet(context),
    );
  }

  void _handleEmergency(BuildContext context) {
    // Show emergency options
    showDialog(
      context: context,
      builder: (context) => _buildEmergencyDialog(context),
    );
  }

  Widget _buildMessageBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            'Quick Messages',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 3.h),

          // Quick message options
          ...[
            'I\'m waiting at the pickup location',
            'Running 5 minutes late',
            'Where exactly are you?',
            'Thank you for the ride',
          ].map((message) => _buildQuickMessageOption(context, theme, message)),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildQuickMessageOption(
      BuildContext context, ThemeData theme, String message) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Message sent: $message",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          textColor: Colors.white,
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyDialog(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'warning',
            color: AppTheme.errorLight,
            size: 24,
          ),
          SizedBox(width: 2.w),
          Text(
            'Emergency',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.errorLight,
            ),
          ),
        ],
      ),
      content: Text(
        'If you feel unsafe or need immediate assistance, please contact emergency services or report this driver.',
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Fluttertoast.showToast(
              msg: "Emergency services contacted",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppTheme.errorLight,
              textColor: Colors.white,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorLight,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Report',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
