import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar variants for different screens in the taxi booking app
enum CustomAppBarVariant {
  /// Standard app bar with back button and title
  standard,

  /// Home screen app bar with location and profile
  home,

  /// Search app bar with search field
  search,

  /// Minimal app bar with just title
  minimal,

  /// Transparent app bar for overlays
  transparent,
}

/// Premium taxi booking app bar implementing Contemporary Cinematic Minimalism
/// Provides contextual navigation and maintains spatial relationships
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.variant,
    this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.onProfileTap,
    this.onLocationTap,
    this.onSearchChanged,
    this.searchController,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  final CustomAppBarVariant variant;
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLocationTap;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: backgroundColor ?? _getBackgroundColor(theme),
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? _getElevation(),
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: _getSystemOverlayStyle(theme),
      toolbarHeight: 64,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: _buildTitle(context),
      leading: _buildLeading(context),
      actions: _buildActions(context),
      flexibleSpace: variant == CustomAppBarVariant.transparent
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(77),
                    Colors.transparent,
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!showBackButton) return null;

    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    if (!canPop) return null;

    return IconButton(
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      iconSize: 20,
      padding: const EdgeInsets.all(12),
      style: IconButton.styleFrom(
        foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
        backgroundColor: variant == CustomAppBarVariant.transparent
            ? Colors.white.withAlpha(26)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomAppBarVariant.home:
        return _buildHomeTitle(context);
      case CustomAppBarVariant.search:
        return _buildSearchField(context);
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.minimal:
      case CustomAppBarVariant.transparent:
        return _buildStandardTitle(theme);
    }
  }

  Widget _buildHomeTitle(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onLocationTap ??
          () => Navigator.pushNamed(context, '/location-detection-screen'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Current Location',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title ?? 'Select pickup location',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: foregroundColor ?? theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(51),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search destinations...',
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStandardTitle(ThemeData theme) {
    if (title == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title!,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: foregroundColor ?? theme.colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final defaultActions = <Widget>[];

    // Add variant-specific actions
    switch (variant) {
      case CustomAppBarVariant.home:
        defaultActions.add(
          IconButton(
            onPressed: onProfileTap ??
                () => Navigator.pushNamed(context, '/user-profile-screen'),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withAlpha(26),
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            padding: const EdgeInsets.all(8),
          ),
        );
        break;
      case CustomAppBarVariant.search:
        defaultActions.add(
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/ride-history-screen'),
            icon: const Icon(Icons.history_rounded),
            iconSize: 20,
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
        break;
      default:
        break;
    }

    // Add custom actions if provided
    if (actions != null) {
      defaultActions.addAll(actions!);
    }

    return defaultActions.isNotEmpty ? defaultActions : null;
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (variant) {
      case CustomAppBarVariant.transparent:
        return Colors.transparent;
      case CustomAppBarVariant.home:
      case CustomAppBarVariant.search:
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.minimal:
        return theme.colorScheme.surface;
    }
  }

  double _getElevation() {
    switch (variant) {
      case CustomAppBarVariant.transparent:
        return 0;
      case CustomAppBarVariant.minimal:
        return 0;
      case CustomAppBarVariant.home:
      case CustomAppBarVariant.search:
      case CustomAppBarVariant.standard:
        return 0;
    }
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: variant == CustomAppBarVariant.transparent
          ? Brightness.light
          : isDark
              ? Brightness.light
              : Brightness.dark,
      statusBarBrightness: variant == CustomAppBarVariant.transparent
          ? Brightness.dark
          : isDark
              ? Brightness.dark
              : Brightness.light,
    );
  }
}
