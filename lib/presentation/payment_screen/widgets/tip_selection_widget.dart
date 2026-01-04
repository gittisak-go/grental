import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TipSelectionWidget extends StatefulWidget {
  final Function(double) onTipChanged;
  final double initialTip;

  const TipSelectionWidget({
    super.key,
    required this.onTipChanged,
    this.initialTip = 0.0,
  });

  @override
  State<TipSelectionWidget> createState() => _TipSelectionWidgetState();
}

class _TipSelectionWidgetState extends State<TipSelectionWidget> {
  double selectedTip = 0.0;
  final TextEditingController customTipController = TextEditingController();
  final List<double> tipPercentages = [15.0, 20.0, 25.0];
  bool isCustomTipSelected = false;

  @override
  void initState() {
    super.initState();
    selectedTip = widget.initialTip;
  }

  @override
  void dispose() {
    customTipController.dispose();
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
                iconName: 'star',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Add Tip (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Show your appreciation for great service',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              ...tipPercentages.map((percentage) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: _buildTipButton(
                        context,
                        '${percentage.toInt()}%',
                        percentage,
                        false,
                      ),
                    ),
                  )),
              Expanded(
                child: _buildTipButton(
                  context,
                  'Custom',
                  0.0,
                  true,
                ),
              ),
            ],
          ),
          if (isCustomTipSelected) ...[
            SizedBox(height: 2.h),
            TextField(
              controller: customTipController,
              keyboardType: TextInputType.number,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Enter custom tip amount',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 2.h,
                ),
              ),
              onChanged: (value) {
                final tipAmount = double.tryParse(value) ?? 0.0;
                setState(() {
                  selectedTip = tipAmount;
                });
                widget.onTipChanged(tipAmount);
              },
            ),
          ],
          if (selectedTip > 0) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tip Amount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${selectedTip.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipButton(
    BuildContext context,
    String label,
    double percentage,
    bool isCustom,
  ) {
    final theme = Theme.of(context);
    final isSelected = isCustom
        ? isCustomTipSelected
        : (!isCustomTipSelected && selectedTip == percentage);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isCustom) {
            isCustomTipSelected = true;
            selectedTip = double.tryParse(customTipController.text) ?? 0.0;
          } else {
            isCustomTipSelected = false;
            selectedTip = percentage;
            customTipController.clear();
          }
        });
        widget.onTipChanged(selectedTip);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
