import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Permission explanation modal for location access
class PermissionExplanationModalWidget extends StatelessWidget {
  const PermissionExplanationModalWidget({
    super.key,
    required this.onAllow,
    required this.onDeny,
  });

  final VoidCallback onAllow;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          width: 85.w,
          constraints: BoxConstraints(maxWidth: 400),
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 8.w,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Location Permission Required',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'TaxiHouse needs access to your location to provide accurate pickup points and real-time tracking for your rides.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'security',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Your location data is encrypted and never shared with third parties.',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDeny,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        side: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Not Now',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAllow,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                      ),
                      child: Text(
                        'Allow Access',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
