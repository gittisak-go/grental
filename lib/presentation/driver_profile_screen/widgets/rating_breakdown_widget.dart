import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RatingBreakdownWidget extends StatelessWidget {
  final Map<String, dynamic> ratingData;
  final List<Map<String, dynamic>> recentComments;

  const RatingBreakdownWidget({
    super.key,
    required this.ratingData,
    required this.recentComments,
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
            'Rating Breakdown',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 3.h),

          // Overall rating
          Row(
            children: [
              Text(
                ratingData["overall"].toString(),
                style: GoogleFonts.inter(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return CustomIconWidget(
                        iconName:
                            index < (ratingData["overall"] as double).floor()
                                ? 'star'
                                : 'star_border',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      );
                    }),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${ratingData["totalRatings"]} ratings',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Rating distribution
          Column(
            children: List.generate(5, (index) {
              final starCount = 5 - index;
              final percentage =
                  (ratingData["distribution"] as List)[index] as double;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                child: Row(
                  children: [
                    Text(
                      '$starCount',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    CustomIconWidget(
                      iconName: 'star',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 12,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Container(
                        height: 0.8.h,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${percentage.toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 4.h),

          // Recent comments section
          Text(
            'Recent Comments',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          // Comments list
          Container(
            height: 20.h,
            child: ListView.separated(
              itemCount: recentComments.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final comment = recentComments[index];
                return _buildCommentCard(context, theme, comment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(
      BuildContext context, ThemeData theme, Map<String, dynamic> comment) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header
          Row(
            children: [
              // Rating stars
              Row(
                children: List.generate(5, (index) {
                  return CustomIconWidget(
                    iconName: index < (comment["rating"] as int)
                        ? 'star'
                        : 'star_border',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 12,
                  );
                }),
              ),
              Spacer(),
              Text(
                comment["date"] as String,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Comment text
          Text(
            comment["comment"] as String,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 1.h),

          // Passenger name
          Text(
            '- ${comment["passengerName"]}',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
