import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class QuickStatsRowWidget extends StatelessWidget {
  final int totalRides;
  final int activeDrivers;
  final double avgRating;
  final double utilization;

  const QuickStatsRowWidget({
    super.key,
    required this.totalRides,
    required this.activeDrivers,
    required this.avgRating,
    required this.utilization,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      child: Row(
        children: [
          Expanded(
            child: _buildStat(
              'Total Rides',
              totalRides.toString(),
              Icons.directions_car_rounded,
              const Color(0xFFE91E63),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStat(
              'Active Drivers',
              activeDrivers.toString(),
              Icons.person_rounded,
              const Color(0xFF5856D6),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStat(
              'Avg Rating',
              avgRating.toStringAsFixed(1),
              Icons.star_rounded,
              const Color(0xFFFF9500),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStat(
              'Utilization',
              '${utilization.toStringAsFixed(0)}%',
              Icons.speed_rounded,
              const Color(0xFF34C759),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 7.sp,
              color: const Color(0xFF8E8E93),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
