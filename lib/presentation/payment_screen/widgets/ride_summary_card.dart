import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RideSummaryCard extends StatelessWidget {
  final Map<String, dynamic> rideDetails;

  const RideSummaryCard({
    super.key,
    required this.rideDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'directions_car',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Ride Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildLocationRow(
            context,
            'radio_button_checked',
            'Pickup',
            rideDetails['pickup'] as String,
            theme.colorScheme.tertiary,
          ),
          SizedBox(height: 1.h),
          _buildLocationRow(
            context,
            'location_on',
            'Destination',
            rideDetails['destination'] as String,
            theme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  'schedule',
                  'Duration',
                  rideDetails['duration'] as String,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildInfoItem(
                  context,
                  'straighten',
                  'Distance',
                  rideDetails['distance'] as String,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context,
    String iconName,
    String label,
    String location,
    Color iconColor,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: iconColor,
              size: 16,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                location,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String iconName,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
