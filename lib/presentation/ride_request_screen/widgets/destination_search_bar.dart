import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DestinationSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<String> recentDestinations;
  final ValueChanged<String>? onDestinationSelected;

  const DestinationSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onTap,
    this.recentDestinations = const [],
    this.onDestinationSelected,
  });

  @override
  State<DestinationSearchBar> createState() => _DestinationSearchBarState();
}

class _DestinationSearchBarState extends State<DestinationSearchBar> {
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = widget.recentDestinations;
  }

  void _filterSuggestions(String query) {
    if (query.isEmpty) {
      _filteredSuggestions = widget.recentDestinations;
    } else {
      _filteredSuggestions = widget.recentDestinations
          .where((destination) =>
              destination.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Add predictive suggestions
      final predictiveSuggestions = [
        'Times Square, New York',
        'Central Park, New York',
        'Brooklyn Bridge, New York',
        'Empire State Building, New York',
        'Statue of Liberty, New York',
      ]
          .where((suggestion) =>
              suggestion.toLowerCase().contains(query.toLowerCase()) &&
              !_filteredSuggestions.contains(suggestion))
          .toList();

      _filteredSuggestions.addAll(predictiveSuggestions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: (value) {
              _filterSuggestions(value);
              setState(() {
                _showSuggestions = value.isNotEmpty;
              });
              widget.onChanged?.call(value);
            },
            onTap: () {
              setState(() {
                _showSuggestions = true;
              });
              widget.onTap?.call();
            },
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Where to?',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        widget.controller.clear();
                        setState(() {
                          _showSuggestions = false;
                        });
                      },
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
            ),
          ),
        ),
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            constraints: BoxConstraints(maxHeight: 30.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 1.h),
              itemCount: _filteredSuggestions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                final isRecent = widget.recentDestinations.contains(suggestion);

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isRecent
                          ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: isRecent ? 'history' : 'location_on',
                      color: isRecent
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    suggestion,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: isRecent
                      ? Text(
                          'Recent destination',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                  onTap: () {
                    widget.controller.text = suggestion;
                    setState(() {
                      _showSuggestions = false;
                    });
                    widget.onDestinationSelected?.call(suggestion);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
