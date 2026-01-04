import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SecurityIndicatorsWidget extends StatelessWidget {
  const SecurityIndicatorsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSecurityBadge(
            context,
            'security',
            'SSL Encrypted',
            theme.colorScheme.tertiary,
          ),
          Container(
            width: 1,
            height: 4.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildSecurityBadge(
            context,
            'verified',
            'PCI Compliant',
            theme.colorScheme.primary,
          ),
          Container(
            width: 1,
            height: 4.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildSecurityBadge(
            context,
            'shield',
            'Secure Payment',
            theme.colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(
    BuildContext context,
    String iconName,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 16,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
