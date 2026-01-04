import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  const ProfileMenuItemWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showArrow = true,
    this.iconColor,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.w),
      child: Padding(
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
            if (trailing != null) ...[
              SizedBox(width: 2.w),
              trailing!,
            ] else if (showArrow) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
