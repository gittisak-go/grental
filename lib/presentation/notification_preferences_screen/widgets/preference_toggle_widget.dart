import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/notification_preference_model.dart';

class PreferenceToggleWidget extends StatelessWidget {
  final NotificationPreferenceModel preference;
  final Function(bool) onChanged;
  final bool isLoading;

  const PreferenceToggleWidget({
    Key? key,
    required this.preference,
    required this.onChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NotificationCategory.getDisplayName(preference.category),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  NotificationCategory.getDescription(preference.category),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (preference.deliveryMethods.isNotEmpty) ...[
                  SizedBox(height: 0.8.h),
                  Wrap(
                    spacing: 1.w,
                    children: preference.deliveryMethods.map((method) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: preference.isEnabled
                              ? Colors.blue.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          method.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                            color: preference.isEnabled
                                ? Colors.blue.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 3.w),
          isLoading
              ? SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade700,
                    ),
                  ),
                )
              : Switch(
                  value: preference.isEnabled,
                  onChanged: onChanged,
                  activeThumbColor: Colors.blue.shade700,
                  activeTrackColor: Colors.blue.shade200,
                ),
        ],
      ),
    );
  }
}
