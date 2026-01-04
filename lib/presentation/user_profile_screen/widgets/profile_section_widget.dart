import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProfileSectionWidget extends StatelessWidget {
  const ProfileSectionWidget({
    super.key,
    required this.title,
    required this.children,
    this.showDivider = true,
  });

  final String title;
  final List<Widget> children;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1 && showDivider)
                  Divider(
                    height: 0.1.h,
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    indent: 4.w,
                    endIndent: 4.w,
                  ),
              ],
            ],
          ),
        ),
        SizedBox(height: 3.h),
      ],
    );
  }
}
