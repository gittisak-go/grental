import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RideHistorySearchBar extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  const RideHistorySearchBar({
    super.key,
    this.initialQuery,
    required this.onSearchChanged,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  @override
  State<RideHistorySearchBar> createState() => _RideHistorySearchBarState();
}

class _RideHistorySearchBarState extends State<RideHistorySearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _isSearchActive = widget.initialQuery?.isNotEmpty ?? false;
    if (_isSearchActive) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String query) {
    widget.onSearchChanged(query);

    if (query.isNotEmpty && !_isSearchActive) {
      setState(() => _isSearchActive = true);
      _animationController.forward();
    } else if (query.isEmpty && _isSearchActive) {
      setState(() => _isSearchActive = false);
      _animationController.reverse();
    }
  }

  void _clearSearch() {
    HapticFeedback.lightImpact();
    _searchController.clear();
    _handleSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isSearchActive
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: _isSearchActive ? 1.5 : 0.5,
                      ),
                      boxShadow: _isSearchActive
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: theme.colorScheme.shadow
                                    .withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _handleSearchChanged,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by destination, driver, or date...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'search',
                            color: _isSearchActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        suffixIcon: _isSearchActive
                            ? GestureDetector(
                                onTap: _clearSearch,
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'close',
                                      color: theme.colorScheme.onSurfaceVariant,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 3.h,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onFilterTap?.call();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: widget.hasActiveFilters
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.hasActiveFilters
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: widget.hasActiveFilters ? 2 : 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.hasActiveFilters
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: widget.hasActiveFilters ? 8 : 4,
                    offset: Offset(0, widget.hasActiveFilters ? 2 : 1),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CustomIconWidget(
                    iconName: 'tune',
                    color: widget.hasActiveFilters
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  if (widget.hasActiveFilters)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onPrimary,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}