import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentCardWidget extends StatelessWidget {
  const PaymentCardWidget({
    super.key,
    required this.cardType,
    required this.lastFourDigits,
    required this.isDefault,
    required this.onTap,
    required this.onDelete,
  });

  final String cardType;
  final String lastFourDigits;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: isDefault
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isDefault ? 2 : 1,
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
              height: 8.w,
              decoration: BoxDecoration(
                color: _getCardColor(cardType),
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getCardIcon(cardType),
                  color: Colors.white,
                  size: 5.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        cardType,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (isDefault) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Text(
                            'Default',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '•••• •••• •••• $lastFourDigits',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: CustomIconWidget(
                iconName: 'delete_outline',
                color: theme.colorScheme.error,
                size: 5.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'american express':
        return const Color(0xFF006FCF);
      default:
        return const Color(0xFF424242);
    }
  }

  String _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
      case 'mastercard':
      case 'american express':
        return 'credit_card';
      default:
        return 'payment';
    }
  }
}
