import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RideHistoryFilterSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const RideHistoryFilterSheet({
    super.key,
    required this.currentFilters,
    required this.onFiltersApplied,
  });

  @override
  State<RideHistoryFilterSheet> createState() => _RideHistoryFilterSheetState();
}

class _RideHistoryFilterSheetState extends State<RideHistoryFilterSheet> {
  late Map<String, dynamic> _filters;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _statusOptions = [
    'All',
    'Completed',
    'Cancelled',
    'Ongoing'
  ];
  final List<String> _paymentOptions = [
    'All',
    'Cash',
    'Credit Card',
    'Digital Wallet'
  ];
  final List<String> _ratingOptions = [
    'All',
    '5 Stars',
    '4+ Stars',
    '3+ Stars',
    '2+ Stars',
    '1+ Stars'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _startDate = _filters['startDate'] as DateTime?;
    _endDate = _filters['endDate'] as DateTime?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeSection(theme),
                  SizedBox(height: 3.h),
                  _buildStatusSection(theme),
                  SizedBox(height: 3.h),
                  _buildPaymentMethodSection(theme),
                  SizedBox(height: 3.h),
                  _buildRatingSection(theme),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filter Rides',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                theme,
                'Start Date',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildDateSelector(
                theme,
                'End Date',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    ThemeData theme,
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: theme.colorScheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}'
                        : 'Select date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selectedDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: selectedDate != null
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ride Status',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        _buildOptionGrid(theme, _statusOptions, 'status'),
      ],
    );
  }

  Widget _buildPaymentMethodSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        _buildOptionGrid(theme, _paymentOptions, 'paymentMethod'),
      ],
    );
  }

  Widget _buildRatingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Driver Rating',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        _buildOptionGrid(theme, _ratingOptions, 'rating'),
      ],
    );
  }

  Widget _buildOptionGrid(
      ThemeData theme, List<String> options, String filterKey) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: options.map((option) {
        final isSelected = _filters[filterKey] == option;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _filters[filterKey] = option;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 0.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              option,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _filters = {
                      'status': 'All',
                      'paymentMethod': 'All',
                      'rating': 'All',
                      'startDate': null,
                      'endDate': null,
                    };
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: Text('Clear All'),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _filters['startDate'] = _startDate;
                  _filters['endDate'] = _endDate;
                  widget.onFiltersApplied(_filters);
                  Navigator.pop(context);
                },
                child: Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
