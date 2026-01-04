import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SafetyInfoWidget extends StatelessWidget {
  final Map<String, dynamic> safetyData;

  const SafetyInfoWidget({
    super.key,
    required this.safetyData,
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
            'Safety & Verification',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 3.h),

          // Safety checks
          Column(
            children: [
              _buildSafetyItem(
                context,
                theme,
                'verified_user',
                'Background Check',
                safetyData["backgroundCheck"] as bool,
                'Comprehensive criminal background verification completed',
              ),
              SizedBox(height: 2.h),
              _buildSafetyItem(
                context,
                theme,
                'security',
                'Insurance Verified',
                safetyData["insuranceVerified"] as bool,
                'Valid commercial insurance policy confirmed',
              ),
              SizedBox(height: 2.h),
              _buildSafetyItem(
                context,
                theme,
                'badge',
                'Platform Certified',
                safetyData["platformCertified"] as bool,
                'Completed platform safety training and certification',
              ),
              SizedBox(height: 2.h),
              _buildSafetyItem(
                context,
                theme,
                'directions_car',
                'Vehicle Inspected',
                safetyData["vehicleInspected"] as bool,
                'Regular vehicle safety inspection up to date',
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Trust indicators
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.successLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.successLight.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'shield',
                  color: AppTheme.successLight,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trusted Driver',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successLight,
                        ),
                      ),
                      Text(
                        'This driver has passed all safety requirements and maintains excellent ratings.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Last updated
          Row(
            children: [
              CustomIconWidget(
                iconName: 'update',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Last updated: ${safetyData["lastUpdated"]}',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyItem(
    BuildContext context,
    ThemeData theme,
    String iconName,
    String title,
    bool isVerified,
    String description,
  ) {
    final color = isVerified ? AppTheme.successLight : AppTheme.errorLight;
    final statusIcon = isVerified ? 'check_circle' : 'cancel';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main icon
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 20,
          ),
        ),

        SizedBox(width: 3.w),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: statusIcon,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
