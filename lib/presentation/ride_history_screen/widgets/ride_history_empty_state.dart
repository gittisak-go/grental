import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RideHistoryEmptyState extends StatelessWidget {
  final bool isSearchResult;
  final String? searchQuery;
  final VoidCallback? onTakeFirstRide;
  final VoidCallback? onClearSearch;

  const RideHistoryEmptyState({
    super.key,
    this.isSearchResult = false,
    this.searchQuery,
    this.onTakeFirstRide,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(theme),
            SizedBox(height: 4.h),
            _buildTitle(theme),
            SizedBox(height: 2.h),
            _buildDescription(theme),
            SizedBox(height: 4.h),
            _buildActionButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circles for depth
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          // Main icon
          CustomIconWidget(
            iconName: isSearchResult ? 'search_off' : 'directions_car',
            color: theme.colorScheme.primary,
            size: isSearchResult ? 48 : 56,
          ),
          // Decorative elements
          if (!isSearchResult) ...[
            Positioned(
              top: 8.w,
              right: 8.w,
              child: Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: AppTheme.warningLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 10.w,
              left: 6.w,
              child: Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    String title;
    if (isSearchResult) {
      title = 'No rides found';
    } else {
      title = 'No rides yet';
    }

    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    String description;
    if (isSearchResult) {
      description = searchQuery != null && searchQuery!.isNotEmpty
          ? 'We couldn\'t find any rides matching "$searchQuery". Try adjusting your search or filters.'
          : 'No rides match your current filters. Try adjusting your search criteria.';
    } else {
      description =
          'Start your journey with RungrojCarRental! Book your first ride and experience premium transportation with professional drivers.';
    }

    return Text(
      description,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    if (isSearchResult) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onClearSearch?.call();
              },
              icon: CustomIconWidget(
                iconName: 'clear',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Navigator.pushNamed(context, '/ride-request-screen');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              label: Text('Book New Ride'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            onTakeFirstRide?.call();
          },
          icon: CustomIconWidget(
            iconName: 'directions_car',
            color: theme.colorScheme.onPrimary,
            size: 20,
          ),
          label: Text('Take Your First Ride'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 2.h),
          ),
        ),
      );
    }
  }
}
