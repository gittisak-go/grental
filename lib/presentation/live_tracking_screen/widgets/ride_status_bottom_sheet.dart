import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RideStatusBottomSheet extends StatefulWidget {
  final Map<String, dynamic> rideData;
  final VoidCallback? onChangeDestination;
  final VoidCallback? onAddStop;
  final VoidCallback? onCancelRide;
  final VoidCallback? onEmergency;

  const RideStatusBottomSheet({
    super.key,
    required this.rideData,
    this.onChangeDestination,
    this.onAddStop,
    this.onCancelRide,
    this.onEmergency,
  });

  @override
  State<RideStatusBottomSheet> createState() => _RideStatusBottomSheetState();
}

class _RideStatusBottomSheetState extends State<RideStatusBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (widget.rideData["progress"] as double?) ?? 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.35,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: EdgeInsets.only(top: 2.h),
                width: 12.w,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  children: [
                    _buildRideStatus(theme),
                    SizedBox(height: 3.h),
                    _buildProgressIndicator(theme),
                    SizedBox(height: 3.h),
                    _buildTimeEstimates(theme),
                    SizedBox(height: 3.h),
                    _buildActionButtons(theme),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRideStatus(ThemeData theme) {
    final status = (widget.rideData["status"] as String?) ?? "En Route";
    final rideId = (widget.rideData["rideId"] as String?) ?? "TH-2024-001";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rideId,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          "Your driver is on the way to pick you up",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trip Progress",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor:
                      theme.colorScheme.outline.withValues(alpha: 0.2),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                  minHeight: 6,
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pickup",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      "${(_progressAnimation.value * 100).toInt()}%",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    Text(
                      "Destination",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeEstimates(ThemeData theme) {
    final eta = (widget.rideData["eta"] as String?) ?? "5 min";
    final distance = (widget.rideData["distance"] as String?) ?? "2.3 km";

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                SizedBox(height: 1.h),
                Text(
                  eta,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  "ETA",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'straighten',
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                SizedBox(height: 1.h),
                Text(
                  distance,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  "Distance",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trip Options",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onChangeDestination,
                icon: CustomIconWidget(
                  iconName: 'edit_location',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                label: const Text("Change Destination"),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onAddStop,
                icon: CustomIconWidget(
                  iconName: 'add_location',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                label: const Text("Add Stop"),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onEmergency,
                icon: CustomIconWidget(
                  iconName: 'emergency',
                  color: theme.colorScheme.onError,
                  size: 18,
                ),
                label: const Text("Emergency"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorLight,
                  foregroundColor: theme.colorScheme.onError,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: TextButton.icon(
                onPressed: widget.onCancelRide,
                icon: CustomIconWidget(
                  iconName: 'cancel',
                  color: theme.colorScheme.error,
                  size: 18,
                ),
                label: const Text("Cancel Ride"),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
