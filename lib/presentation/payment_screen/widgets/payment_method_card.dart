import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentMethodCard extends StatelessWidget {
  final Map<String, dynamic> paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getPaymentIcon(paymentMethod['type'] as String),
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentMethod['name'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    paymentMethod['details'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'check',
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPaymentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'card':
        return 'credit_card';
      case 'apple_pay':
        return 'apple';
      case 'google_pay':
        return 'google';
      case 'cash':
        return 'money';
      case 'paypal':
        return 'payment';
      default:
        return 'payment';
    }
  }
}
