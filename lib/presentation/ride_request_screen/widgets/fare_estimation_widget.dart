import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FareEstimationWidget extends StatelessWidget {
  final String baseFare;
  final String estimatedTotal;
  final VoidCallback? onInfoTap;
  final bool showSurgeNotification;

  const FareEstimationWidget({
    super.key,
    required this.baseFare,
    required this.estimatedTotal,
    this.onInfoTap,
    this.showSurgeNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showSurgeNotification
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Surge notification
          if (showSurgeNotification)
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'High Demand Area',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Prices are temporarily higher due to increased demand',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Fare breakdown header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fare Estimation',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              InkWell(
                onTap: onInfoTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: CustomIconWidget(
                    iconName: 'info_outline',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Fare breakdown items
          _buildFareItem(
            'ค่าเช่าพื้นฐาน',
            baseFare,
            theme,
          ),
          SizedBox(height: 1.h),
          _buildFareItem(
            'ระยะทาง (3.7 กม.)',
            '฿96',
            theme,
          ),
          SizedBox(height: 1.h),
          _buildFareItem(
            'เวลา (8 นาที)',
            '฿48',
            theme,
          ),
          if (showSurgeNotification) ...[
            SizedBox(height: 1.h),
            _buildFareItem(
              'ค่าบริการเพิ่มเติม (1.5x)',
              '฿62',
              theme,
              isHighlight: true,
            ),
          ],
          SizedBox(height: 1.h),
          _buildFareItem(
            'ค่าบริการ',
            '฿40',
            theme,
          ),
          SizedBox(height: 2.h),
          // Divider
          Container(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 2.h),
          // Total fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                estimatedTotal,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Disclaimer
          Text(
            'Final fare may vary based on actual distance and time',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFareItem(
    String label,
    String amount,
    ThemeData theme, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isHighlight
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isHighlight
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
