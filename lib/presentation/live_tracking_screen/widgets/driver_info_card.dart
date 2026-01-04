import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DriverInfoCard extends StatelessWidget {
  final Map<String, dynamic> driverData;
  final VoidCallback? onCallPressed;
  final VoidCallback? onMessagePressed;

  const DriverInfoCard({
    super.key,
    required this.driverData,
    this.onCallPressed,
    this.onMessagePressed,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Driver Avatar
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomImageWidget(
                imageUrl: (driverData["avatar"] as String?) ?? "",
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
                semanticLabel: (driverData["semanticLabel"] as String?) ??
                    "Driver profile photo",
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (driverData["name"] as String?) ?? "Driver",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'star',
                      color: AppTheme.primaryLight,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      "${(driverData["rating"] as double?)?.toStringAsFixed(1) ?? "5.0"}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        "${(driverData["vehicle"] as String?) ?? "Vehicle"} • ${(driverData["plateNumber"] as String?) ?? "ABC123"}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: onMessagePressed,
                  icon: CustomIconWidget(
                    iconName: 'message',
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: onCallPressed,
                  icon: CustomIconWidget(
                    iconName: 'phone',
                    color: AppTheme.successLight,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
