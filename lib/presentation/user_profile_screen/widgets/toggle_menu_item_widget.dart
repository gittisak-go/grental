import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ToggleMenuItemWidget extends StatelessWidget {
  const ToggleMenuItemWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: (iconColor ?? theme.colorScheme.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.colorScheme.primary,
            inactiveThumbColor: theme.colorScheme.outline,
            inactiveTrackColor:
                theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
