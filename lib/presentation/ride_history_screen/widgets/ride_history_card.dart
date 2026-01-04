import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RideHistoryCard extends StatelessWidget {
  final Map<String, dynamic> rideData;
  final VoidCallback? onTap;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onRebook;
  final VoidCallback? onRateDriver;
  final VoidCallback? onReportIssue;

  const RideHistoryCard({
    super.key,
    required this.rideData,
    this.onTap,
    this.onViewReceipt,
    this.onRebook,
    this.onRateDriver,
    this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted =
        (rideData['status'] as String).toLowerCase() == 'completed';
    final isCancelled =
        (rideData['status'] as String).toLowerCase() == 'cancelled';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(rideData['id']),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onViewReceipt?.call();
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: Icons.receipt_rounded,
              label: 'Receipt',
              borderRadius: BorderRadius.circular(12),
            ),
            if (isCompleted) ...[
              SlidableAction(
                onPressed: (_) {
                  HapticFeedback.lightImpact();
                  onRebook?.call();
                },
                backgroundColor: AppTheme.successLight,
                foregroundColor: Colors.white,
                icon: Icons.refresh_rounded,
                label: 'Rebook',
                borderRadius: BorderRadius.circular(12),
              ),
              SlidableAction(
                onPressed: (_) {
                  HapticFeedback.lightImpact();
                  onRateDriver?.call();
                },
                backgroundColor: AppTheme.warningLight,
                foregroundColor: Colors.white,
                icon: Icons.star_rounded,
                label: 'Rate',
                borderRadius: BorderRadius.circular(12),
              ),
            ],
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onReportIssue?.call();
              },
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              icon: Icons.report_rounded,
              label: 'Report',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap?.call();
          },
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                SizedBox(height: 2.h),
                _buildRouteInfo(theme),
                SizedBox(height: 2.h),
                _buildRideDetails(theme),
                SizedBox(height: 1.5.h),
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final DateTime rideDate = rideData['date'] as DateTime;
    final String formattedDate =
        '${rideDate.month.toString().padLeft(2, '0')}/${rideDate.day.toString().padLeft(2, '0')}/${rideDate.year}';
    final String formattedTime =
        '${rideDate.hour > 12 ? rideDate.hour - 12 : rideDate.hour == 0 ? 12 : rideDate.hour}:${rideDate.minute.toString().padLeft(2, '0')} ${rideDate.hour >= 12 ? 'PM' : 'AM'}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                formattedTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(theme),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final String status = rideData['status'] as String;
    Color badgeColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        badgeColor = AppTheme.successLight.withValues(alpha: 0.1);
        textColor = AppTheme.successLight;
        break;
      case 'cancelled':
        badgeColor = theme.colorScheme.error.withValues(alpha: 0.1);
        textColor = theme.colorScheme.error;
        break;
      case 'ongoing':
        badgeColor = theme.colorScheme.primary.withValues(alpha: 0.1);
        textColor = theme.colorScheme.primary;
        break;
      default:
        badgeColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1);
        textColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRouteInfo(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                rideData['pickupAddress'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
                            .withValues(alpha: 0.3),
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
            Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                rideData['destinationAddress'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRideDetails(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageWidget(
              imageUrl: rideData['driverPhoto'] as String,
              width: 12.w,
              height: 12.w,
              fit: BoxFit.cover,
              semanticLabel: rideData['driverPhotoSemanticLabel'] as String,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rideData['driverName'] as String,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.warningLight,
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${rideData['driverRating']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${rideData['vehicleModel']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              rideData['fare'] as String,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              rideData['duration'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        _buildPaymentMethodIcon(theme),
        SizedBox(width: 2.w),
        Text(
          rideData['paymentMethod'] as String,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if ((rideData['rating'] as int?) != null &&
            (rideData['rating'] as int) > 0) ...[
          Row(
            children: [
              Text(
                'You rated: ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => CustomIconWidget(
                    iconName: index < (rideData['rating'] as int)
                        ? 'star'
                        : 'star_border',
                    color: index < (rideData['rating'] as int)
                        ? AppTheme.warningLight
                        : theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodIcon(ThemeData theme) {
    final String paymentMethod =
        (rideData['paymentMethod'] as String).toLowerCase();
    IconData iconData;

    switch (paymentMethod) {
      case 'cash':
        iconData = Icons.payments_rounded;
        break;
      case 'credit card':
      case 'debit card':
        iconData = Icons.credit_card_rounded;
        break;
      case 'digital wallet':
      case 'apple pay':
      case 'google pay':
        iconData = Icons.account_balance_wallet_rounded;
        break;
      default:
        iconData = Icons.payment_rounded;
    }

    return Container(
      padding: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: CustomIconWidget(
        iconName: iconData.codePoint.toString(),
        color: theme.colorScheme.primary,
        size: 16,
      ),
    );
  }
}
