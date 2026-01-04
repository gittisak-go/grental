import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab bar variants for different content types
enum CustomTabBarVariant {
  /// Standard tabs with equal width
  standard,

  /// Scrollable tabs for many options
  scrollable,

  /// Segmented control style
  segmented,

  /// Minimal tabs without indicators
  minimal,
}

/// Tab item data structure
class TabItem {
  const TabItem({
    required this.label,
    this.icon,
    this.badge,
  });

  final String label;
  final IconData? icon;
  final String? badge;
}

/// Premium taxi booking tab bar implementing spatial navigation flow
/// Provides smooth transitions and maintains visual hierarchy
class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.variant,
    required this.tabs,
    required this.selectedIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.isScrollable = false,
  });

  final CustomTabBarVariant variant;
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context, theme);
      case CustomTabBarVariant.minimal:
        return _buildMinimalTabBar(context, theme);
      case CustomTabBarVariant.standard:
      case CustomTabBarVariant.scrollable:
        return _buildStandardTabBar(context, theme);
    }
  }

  Widget _buildStandardTabBar(BuildContext context, ThemeData theme) {
    final selectedColor = this.selectedColor ?? theme.colorScheme.primary;
    final unselectedColor =
        this.unselectedColor ?? theme.colorScheme.onSurfaceVariant;
    final indicatorColor = this.indicatorColor ?? selectedColor;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withAlpha(51),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        isScrollable: variant == CustomTabBarVariant.scrollable || isScrollable,
        labelColor: selectedColor,
        unselectedLabelColor: unselectedColor,
        indicatorColor: indicatorColor,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.1,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: _handleTap,
        tabs: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Tab(
            child: _buildTabContent(theme, tab, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context, ThemeData theme) {
    final selectedColor = this.selectedColor ?? theme.colorScheme.primary;
    final unselectedColor =
        this.unselectedColor ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(51),
          width: 0.5,
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => _handleTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildTabContent(
                  theme,
                  tab,
                  isSelected,
                  textColor: isSelected
                      ? theme.colorScheme.onPrimary
                      : unselectedColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMinimalTabBar(BuildContext context, ThemeData theme) {
    final selectedColor = this.selectedColor ?? theme.colorScheme.primary;
    final unselectedColor =
        this.unselectedColor ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => _handleTap(index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: _buildTabContent(
                  theme,
                  tab,
                  isSelected,
                  textColor: isSelected ? selectedColor : unselectedColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(
    ThemeData theme,
    TabItem tab,
    bool isSelected, {
    Color? textColor,
  }) {
    final color = textColor ??
        (isSelected
            ? (selectedColor ?? theme.colorScheme.primary)
            : (unselectedColor ?? theme.colorScheme.onSurfaceVariant));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (tab.icon != null) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Icon(
              tab.icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: color,
              letterSpacing: -0.1,
            ),
            child: Text(
              tab.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (tab.badge != null) ...[
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              tab.badge!,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onError,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _handleTap(int index) {
    // Provide haptic feedback for premium feel
    HapticFeedback.selectionClick();

    // Call custom onTap if provided
    onTap?.call(index);
  }
}

/// Tab bar controller for managing tab state
class CustomTabBarController extends ChangeNotifier {
  CustomTabBarController({int initialIndex = 0})
      : _selectedIndex = initialIndex;

  int _selectedIndex;
  int get selectedIndex => _selectedIndex;

  void selectTab(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void nextTab(int maxTabs) {
    if (_selectedIndex < maxTabs - 1) {
      selectTab(_selectedIndex + 1);
    }
  }

  void previousTab() {
    if (_selectedIndex > 0) {
      selectTab(_selectedIndex - 1);
    }
  }
}
