import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RideHistorySkeletonLoader extends StatefulWidget {
  final int itemCount;

  const RideHistorySkeletonLoader({
    super.key,
    this.itemCount = 5,
  });

  @override
  State<RideHistorySkeletonLoader> createState() =>
      _RideHistorySkeletonLoaderState();
}

class _RideHistorySkeletonLoaderState extends State<RideHistorySkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonHeader(theme),
                  SizedBox(height: 2.h),
                  _buildSkeletonRoute(theme),
                  SizedBox(height: 2.h),
                  _buildSkeletonDetails(theme),
                  SizedBox(height: 1.5.h),
                  _buildSkeletonFooter(theme),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkeletonBox(theme, width: 25.w, height: 2.h),
              SizedBox(height: 1.h),
              _buildSkeletonBox(theme, width: 20.w, height: 1.5.h),
            ],
          ),
        ),
        _buildSkeletonBox(theme, width: 20.w, height: 3.h, borderRadius: 20),
      ],
    );
  }

  Widget _buildSkeletonRoute(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            _buildSkeletonBox(theme, width: 3.w, height: 3.w, borderRadius: 50),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSkeletonBox(theme, height: 2.h),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Container(
              width: 1.w,
              height: 4.h,
              margin: EdgeInsets.only(left: 1.w),
              child: Column(
                children: List.generate(
                  6,
                  (index) => Expanded(
                    child: Container(
                      width: 1,
                      margin: EdgeInsets.symmetric(vertical: 0.2.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.1 * _animation.value),
                        borderRadius: BorderRadius.circular(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildSkeletonBox(theme, width: 3.w, height: 3.w, borderRadius: 50),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSkeletonBox(theme, height: 2.h),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonDetails(ThemeData theme) {
    return Row(
      children: [
        _buildSkeletonBox(theme, width: 12.w, height: 12.w, borderRadius: 8),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkeletonBox(theme, width: 30.w, height: 2.h),
              SizedBox(height: 1.h),
              Row(
                children: [
                  _buildSkeletonBox(theme, width: 4.w, height: 1.5.h),
                  SizedBox(width: 2.w),
                  _buildSkeletonBox(theme, width: 25.w, height: 1.5.h),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildSkeletonBox(theme, width: 20.w, height: 2.h),
            SizedBox(height: 1.h),
            _buildSkeletonBox(theme, width: 15.w, height: 1.5.h),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonFooter(ThemeData theme) {
    return Row(
      children: [
        _buildSkeletonBox(theme, width: 8.w, height: 3.h, borderRadius: 6),
        SizedBox(width: 2.w),
        _buildSkeletonBox(theme, width: 25.w, height: 1.5.h),
        const Spacer(),
        _buildSkeletonBox(theme, width: 30.w, height: 1.5.h),
      ],
    );
  }

  Widget _buildSkeletonBox(
    ThemeData theme, {
    double? width,
    required double height,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant
            .withValues(alpha: 0.1 * _animation.value),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
