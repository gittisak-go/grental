import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FareBreakdownCard extends StatelessWidget {
  final Map<String, dynamic> fareDetails;

  const FareBreakdownCard({
    super.key,
    required this.fareDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fareBreakdown =
        fareDetails['breakdown'] as List<Map<String, dynamic>>;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fare Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ...fareBreakdown.map((item) => _buildFareItem(
                context,
                item['label'] as String,
                item['amount'] as String,
                item['isTotal'] as bool? ?? false,
              )),
          if (fareDetails['discount'] != null) ...[
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              height: 3.h,
            ),
            _buildFareItem(
              context,
              'Discount Applied',
              '-${fareDetails['discount']}',
              false,
              isDiscount: true,
            ),
          ],
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            height: 3.h,
          ),
          _buildFareItem(
            context,
            'Total Amount',
            fareDetails['total'] as String,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildFareItem(
    BuildContext context,
    String label,
    String amount,
    bool isTotal, {
    bool isDiscount = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: isTotal
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    )
                  : theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            amount,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDiscount
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.onSurface,
                  ),
          ),
        ],
      ),
    );
  }
}
