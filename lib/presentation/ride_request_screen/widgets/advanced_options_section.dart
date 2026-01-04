import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AdvancedOptionsSection extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  final ValueChanged<DateTime?>? onScheduleChanged;
  final ValueChanged<String>? onSpecialRequestChanged;
  final ValueChanged<String>? onPromoCodeChanged;

  const AdvancedOptionsSection({
    super.key,
    this.isExpanded = false,
    this.onToggle,
    this.onScheduleChanged,
    this.onSpecialRequestChanged,
    this.onPromoCodeChanged,
  });

  @override
  State<AdvancedOptionsSection> createState() => _AdvancedOptionsSectionState();
}

class _AdvancedOptionsSectionState extends State<AdvancedOptionsSection> {
  final TextEditingController _specialRequestController =
      TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();
  DateTime? _scheduledTime;
  bool _isPromoCodeApplied = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: widget.onToggle,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Advanced Options',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: widget.isExpanded ? null : 0,
            child: widget.isExpanded
                ? Column(
                    children: [
                      Container(
                        height: 1,
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Schedule ride option
                            _buildScheduleOption(theme),
                            SizedBox(height: 3.h),
                            // Special requests
                            _buildSpecialRequestsOption(theme),
                            SizedBox(height: 3.h),
                            // Promo code
                            _buildPromoCodeOption(theme),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleOption(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'schedule',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Schedule Ride',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () => _selectScheduleTime(theme),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _scheduledTime != null
                      ? 'Scheduled for ${_formatDateTime(_scheduledTime!)}'
                      : 'Book for later',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _scheduledTime != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: _scheduledTime != null
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                CustomIconWidget(
                  iconName: _scheduledTime != null
                      ? 'check_circle'
                      : 'calendar_today',
                  color: _scheduledTime != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRequestsOption(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'message',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Special Requests',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _specialRequestController,
          onChanged: widget.onSpecialRequestChanged,
          maxLines: 3,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Any special requests for your driver?',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(3.w),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCodeOption(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'local_offer',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Promo Code',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoCodeController,
                onChanged: widget.onPromoCodeChanged,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor:
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(3.w),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            ElevatedButton(
              onPressed: _applyPromoCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPromoCodeApplied
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                foregroundColor: _isPromoCodeApplied
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isPromoCodeApplied ? 'Applied' : 'Apply',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (_isPromoCodeApplied)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Promo code applied! You saved \$2.50',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _selectScheduleTime(ThemeData theme) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
        builder: (context, child) {
          return Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: theme.colorScheme.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        final scheduledDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        setState(() {
          _scheduledTime = scheduledDateTime;
        });
        widget.onScheduleChanged?.call(scheduledDateTime);
      }
    }
  }

  void _applyPromoCode() {
    if (_promoCodeController.text.isNotEmpty) {
      setState(() {
        _isPromoCodeApplied = !_isPromoCodeApplied;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, ${hour == 0 ? 12 : hour}:$minute $period';
  }

  @override
  void dispose() {
    _specialRequestController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }
}
