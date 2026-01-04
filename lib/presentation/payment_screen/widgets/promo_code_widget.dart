import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PromoCodeWidget extends StatefulWidget {
  final Function(String, double) onPromoApplied;
  final VoidCallback onPromoRemoved;

  const PromoCodeWidget({
    super.key,
    required this.onPromoApplied,
    required this.onPromoRemoved,
  });

  @override
  State<PromoCodeWidget> createState() => _PromoCodeWidgetState();
}

class _PromoCodeWidgetState extends State<PromoCodeWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController promoController = TextEditingController();
  bool isPromoApplied = false;
  String appliedPromoCode = '';
  double discountAmount = 0.0;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Mock promo codes for demonstration
  final Map<String, double> validPromoCodes = {
    'SAVE20': 20.0,
    'FIRST10': 10.0,
    'WELCOME15': 15.0,
    'STUDENT5': 5.0,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    promoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_offer',
                color: theme.colorScheme.tertiary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Promo Code',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (!isPromoApplied) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoController,
                    style: theme.textTheme.bodyMedium,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 2.h,
                      ),
                      suffixIcon: isLoading
                          ? Padding(
                              padding: EdgeInsets.all(3.w),
                              child: SizedBox(
                                width: 4.w,
                                height: 4.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _applyPromoCode(),
                  ),
                ),
                SizedBox(width: 2.w),
                ElevatedButton(
                  onPressed: isLoading ? null : _applyPromoCode,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                  ),
                  child: Text('Apply'),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Try: SAVE20, FIRST10, WELCOME15, STUDENT5',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promo Applied: $appliedPromoCode',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'You saved \$${discountAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _removePromoCode,
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      padding: EdgeInsets.all(1.w),
                      constraints: BoxConstraints(
                        minWidth: 8.w,
                        minHeight: 8.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _applyPromoCode() async {
    final promoCode = promoController.text.trim().toUpperCase();

    if (promoCode.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (validPromoCodes.containsKey(promoCode)) {
      final discount = validPromoCodes[promoCode]!;

      setState(() {
        isPromoApplied = true;
        appliedPromoCode = promoCode;
        discountAmount = discount;
        isLoading = false;
      });

      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      widget.onPromoApplied(promoCode, discount);
    } else {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid promo code. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _removePromoCode() {
    setState(() {
      isPromoApplied = false;
      appliedPromoCode = '';
      discountAmount = 0.0;
      promoController.clear();
    });

    widget.onPromoRemoved();
  }
}
