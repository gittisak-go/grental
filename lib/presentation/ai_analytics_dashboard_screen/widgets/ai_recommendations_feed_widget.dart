import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AiRecommendationsFeedWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  final bool isLoading;
  final Function(Map<String, dynamic>) onActionTap;

  const AiRecommendationsFeedWidget({
    super.key,
    required this.recommendations,
    required this.isLoading,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'AI Recommendations',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              const Spacer(),
              if (!isLoading)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.3.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withAlpha(26),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    '${recommendations.length} actions',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: const Color(0xFF34C759),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          isLoading
              ? _buildLoadingState()
              : recommendations.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: recommendations
                      .map((rec) => _buildRecommendationCard(rec))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    final priority = rec['priority'] as String? ?? 'medium';
    final type = rec['type'] as String? ?? 'general';
    final title = rec['title'] as String? ?? '';
    final description = rec['description'] as String? ?? '';
    final action = rec['action'] as String? ?? 'Apply';

    final priorityColor = priority == 'high'
        ? const Color(0xFFFF3B30)
        : priority == 'medium'
        ? const Color(0xFFFF9500)
        : const Color(0xFF34C759);

    final typeIcon = _getTypeIcon(type);

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: priorityColor.withAlpha(51)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: priorityColor.withAlpha(26),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(typeIcon, color: priorityColor, size: 18),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1C1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 1.5.w,
                        vertical: 0.2.h,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        priority.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w700,
                          color: priorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: const Color(0xFF8E8E93),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: () => onActionTap(rec),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      action,
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'pricing':
        return Icons.attach_money_rounded;
      case 'fleet':
        return Icons.directions_car_rounded;
      case 'maintenance':
        return Icons.build_rounded;
      case 'driver':
        return Icons.person_rounded;
      case 'demand':
        return Icons.trending_up_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          height: 10.h,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(51),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Text(
          'Tap refresh to generate AI recommendations',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: const Color(0xFF8E8E93),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
