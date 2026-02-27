import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class RevenueTrendWidget extends StatelessWidget {
  final List<Map<String, dynamic>> revenueData;
  final double totalRevenue;
  final double revenueGrowth;

  const RevenueTrendWidget({
    super.key,
    required this.revenueData,
    required this.totalRevenue,
    required this.revenueGrowth,
  });

  List<FlSpot> _buildSpots() {
    if (revenueData.isEmpty) {
      return List.generate(7, (i) => FlSpot(i.toDouble(), 0));
    }
    return revenueData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['amount'] as num).toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = revenueGrowth >= 0;
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
                Icons.trending_up_rounded,
                color: Color(0xFFE91E63),
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Revenue Trends',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFF34C759).withAlpha(26)
                      : const Color(0xFFFF3B30).withAlpha(26),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10,
                      color: isPositive
                          ? const Color(0xFF34C759)
                          : const Color(0xFFFF3B30),
                    ),
                    Text(
                      '${revenueGrowth.abs().toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: isPositive
                            ? const Color(0xFF34C759)
                            : const Color(0xFFFF3B30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            '฿${totalRevenue.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          Text(
            'Total Revenue (7 days)',
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: const Color(0xFF8E8E93),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 15.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.withAlpha(51), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        final idx = value.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Text(
                            days[idx],
                            style: GoogleFonts.inter(
                              fontSize: 8.sp,
                              color: const Color(0xFF8E8E93),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _buildSpots(),
                    isCurved: true,
                    color: const Color(0xFFE91E63),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFE91E63).withAlpha(77),
                          const Color(0xFFE91E63).withAlpha(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
