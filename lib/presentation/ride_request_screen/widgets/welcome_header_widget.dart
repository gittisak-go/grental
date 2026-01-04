import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_icon_widget.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  final String userName;
  final VoidCallback onNotificationTap;

  const WelcomeHeaderWidget({
    super.key,
    required this.userName,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                userName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onNotificationTap,
                  icon: CustomIconWidget(
                    iconName: 'notifications_outlined',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
