import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class DriverPerformanceWidget extends StatelessWidget {
  final List<Map<String, dynamic>> drivers;
  final bool isLoading;

  const DriverPerformanceWidget({
    super.key,
    required this.drivers,
    required this.isLoading,
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
              const Icon(
                Icons.people_alt_rounded,
                color: Color(0xFFE91E63),
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Driver Performance',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              const Spacer(),
              Text(
                'AI Scored',
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          isLoading
              ? _buildSkeleton()
              : drivers.isEmpty
              ? _buildEmpty()
              : Column(
                  children: drivers
                      .take(4)
                      .map((d) => _buildDriverRow(d))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildDriverRow(Map<String, dynamic> driver) {
    final score = (driver['score'] as num?)?.toDouble() ?? 0.0;
    final name = driver['name'] as String? ?? 'Driver';
    final trips = driver['trips'] as int? ?? 0;
    final rating = (driver['rating'] as num?)?.toDouble() ?? 0.0;
    final tip = driver['tip'] as String? ?? '';
    final scoreColor = score >= 80
        ? const Color(0xFF34C759)
        : score >= 60
        ? const Color(0xFFFF9500)
        : const Color(0xFFFF3B30);

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE91E63).withAlpha(26),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'D',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFE91E63),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$trips trips · ⭐ ${rating.toStringAsFixed(1)}',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: scoreColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '${score.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: const Color(0xFFE5E5EA),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 4,
            ),
          ),
          if (tip.isNotEmpty) ...[
            SizedBox(height: 0.8.h),
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 12,
                  color: Color(0xFFFF9500),
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    tip,
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: const Color(0xFF8E8E93),
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          height: 8.h,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(51),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'No driver data available',
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          color: const Color(0xFF8E8E93),
        ),
      ),
    );
  }
}
