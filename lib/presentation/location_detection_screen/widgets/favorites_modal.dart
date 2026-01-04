import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Modal for displaying and managing favorite locations
class FavoritesModal extends StatefulWidget {
  const FavoritesModal({
    super.key,
    required this.favoriteLocations,
    this.onLocationSelected,
    this.onAddFavorite,
  });

  final List<Map<String, dynamic>> favoriteLocations;
  final Function(Map<String, dynamic>)? onLocationSelected;
  final VoidCallback? onAddFavorite;

  @override
  State<FavoritesModal> createState() => _FavoritesModalState();
}

class _FavoritesModalState extends State<FavoritesModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay
            GestureDetector(
              onTap: _closeModal,
              child: Container(
                color:
                    Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
              ),
            ),

            // Modal content
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: 70.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildHeader(theme),
                      Expanded(
                        child: _buildContent(theme),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              'Favorite Locations',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _closeModal,
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (widget.favoriteLocations.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: widget.favoriteLocations.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == widget.favoriteLocations.length) {
          return _buildAddFavoriteButton(theme);
        }

        final location = widget.favoriteLocations[index];
        return _buildFavoriteCard(theme, location, index);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'favorite_border',
              color: theme.colorScheme.onSurfaceVariant,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorite Locations',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your frequently visited places for quick access',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildAddFavoriteButton(theme),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
      ThemeData theme, Map<String, dynamic> location, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          widget.onLocationSelected?.call(location);
          _closeModal();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getLocationTypeColor(location['type'] as String)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: _getLocationTypeIcon(location['type'] as String),
                  color: _getLocationTypeColor(location['type'] as String),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location['name'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location['address'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddFavoriteButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: OutlinedButton.icon(
        onPressed: () {
          widget.onAddFavorite?.call();
          _closeModal();
        },
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.primary,
          size: 20,
        ),
        label: Text(
          'Add Favorite Location',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _getLocationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return 'home';
      case 'work':
        return 'work';
      case 'gym':
        return 'fitness_center';
      case 'restaurant':
        return 'restaurant';
      case 'shopping':
        return 'shopping_bag';
      default:
        return 'place';
    }
  }

  Color _getLocationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return AppTheme.primaryLight;
      case 'work':
        return AppTheme.secondaryLight;
      case 'gym':
        return AppTheme.successLight;
      case 'restaurant':
        return AppTheme.warningLight;
      case 'shopping':
        return AppTheme.accentLight;
      default:
        return AppTheme.primaryLight;
    }
  }
}
