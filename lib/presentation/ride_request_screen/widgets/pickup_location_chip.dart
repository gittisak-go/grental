import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PickupLocationChip extends StatelessWidget {
  final String location;
  final VoidCallback? onEdit;
  final VoidCallback? onDismiss;

  const PickupLocationChip({
    super.key,
    required this.location,
    this.onEdit,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Dismissible(
        key: Key('pickup_location_chip'),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) => onDismiss?.call(),
        background: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 4.w),
          child: CustomIconWidget(
            iconName: 'delete',
            color: theme.colorScheme.error,
            size: 20,
          ),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 4.w),
          child: CustomIconWidget(
            iconName: 'delete',
            color: theme.colorScheme.error,
            size: 20,
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Location',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: CustomIconWidget(
                    iconName: 'edit',
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
