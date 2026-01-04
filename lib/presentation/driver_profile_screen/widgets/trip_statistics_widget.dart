import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TripStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic> statisticsData;

  const TripStatisticsWidget({
    super.key,
    required this.statisticsData,
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
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Trip Statistics',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 3.h),

          // Statistics grid
          Row(
            children: [
              // Total rides
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'directions_car',
                  'Total Rides',
                  statisticsData["totalRides"].toString(),
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),

              SizedBox(width: 3.w),

              // Years driving
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'schedule',
                  'Years Driving',
                  statisticsData["yearsExperience"].toString(),
                  AppTheme.successLight,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Specializations
          Text(
            'Specializations',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          // Specialization chips
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: (statisticsData["specializations"] as List)
                .map((specialization) {
              return _buildSpecializationChip(
                  context, theme, specialization as String);
            }).toList(),
          ),

          SizedBox(height: 3.h),

          // Additional stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat(
                context,
                theme,
                'thumb_up',
                'Acceptance Rate',
                '${statisticsData["acceptanceRate"]}%',
              ),
              _buildMiniStat(
                context,
                theme,
                'cancel',
                'Cancellation Rate',
                '${statisticsData["cancellationRate"]}%',
              ),
              _buildMiniStat(
                context,
                theme,
                'access_time',
                'Avg Response',
                '${statisticsData["avgResponseTime"]}min',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme,
    String iconName,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationChip(
      BuildContext context, ThemeData theme, String specialization) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 1.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        specialization,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    ThemeData theme,
    String iconName,
    String label,
    String value,
  ) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
