import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AiInsightsHeroWidget extends StatelessWidget {
  final String aiInsight;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AiInsightsHeroWidget({
    super.key,
    required this.aiInsight,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'AI-Powered Insights',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 16,
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          isLoading
              ? Column(
                  children: List.generate(
                    3,
                    (i) => Container(
                      margin: EdgeInsets.only(bottom: 0.8.h),
                      height: 10,
                      width: i == 2 ? 60.w : double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(77),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                )
              : Text(
                  aiInsight.isEmpty
                      ? 'Tap refresh to generate AI insights for your fleet performance and revenue optimization.'
                      : aiInsight,
                  style: GoogleFonts.inter(
                    color: Colors.white.withAlpha(230),
                    fontSize: 12.sp,
                    height: 1.5,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              _buildTag('Fleet Optimization'),
              SizedBox(width: 2.w),
              _buildTag('Revenue +12%'),
              SizedBox(width: 2.w),
              _buildTag('Peak Hours'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white.withAlpha(77)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
