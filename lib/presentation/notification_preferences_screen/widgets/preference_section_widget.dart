import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/notification_preference_model.dart';
import './preference_toggle_widget.dart';

class PreferenceSectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<NotificationPreferenceModel> preferences;
  final Function(NotificationPreferenceModel, bool) onToggle;
  final Set<String> loadingPreferences;

  const PreferenceSectionWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.preferences,
    required this.onToggle,
    required this.loadingPreferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (preferences.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: Colors.blue.shade700),
              SizedBox(width: 3.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.5.h),
        ...preferences.map((pref) {
          return PreferenceToggleWidget(
            preference: pref,
            onChanged: (value) => onToggle(pref, value),
            isLoading: loadingPreferences.contains(pref.id),
          );
        }).toList(),
        SizedBox(height: 2.h),
      ],
    );
  }
}
