import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Retry modal for network timeout scenarios
class RetryModalWidget extends StatelessWidget {
  const RetryModalWidget({
    super.key,
    required this.onRetry,
    required this.onCancel,
  });

  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          width: 80.w,
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
              CustomIconWidget(
                iconName: 'wifi_off',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 12.w,
              ),
              SizedBox(height: 3.h),
              Text(
                'Connection Timeout',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'Unable to initialize services. Please check your internet connection and try again.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        side: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Cancel',
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
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                      ),
                      child: Text(
                        'Retry',
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
