import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VehicleSelectionCarousel extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int>? onVehicleSelected;
  final ValueChanged<Map<String, dynamic>>? onVehicleLongPress;

  const VehicleSelectionCarousel({
    super.key,
    this.selectedIndex = 0,
    this.onVehicleSelected,
    this.onVehicleLongPress,
  });

  @override
  State<VehicleSelectionCarousel> createState() =>
      _VehicleSelectionCarouselState();
}

class _VehicleSelectionCarouselState extends State<VehicleSelectionCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _vehicles = [
    {
      "id": 1,
      "type": "TaxiHouse Standard",
      "description": "Comfortable rides for everyday trips",
      "image":
          "https://images.unsplash.com/photo-1726003514379-033ea2ef59f5",
      "semanticLabel":
          "Silver sedan car parked on city street with modern buildings in background",
      "capacity": "4 passengers",
      "estimatedArrival": "3 min",
      "price": "\$12.50",
      "pricePerMile": "\$2.10",
      "features": ["Air Conditioning", "Music System", "Phone Charger"],
      "available": true,
    },
    {
      "id": 2,
      "type": "TaxiHouse Premium",
      "description": "Luxury vehicles with premium amenities",
      "image":
          "https://images.unsplash.com/photo-1701985344392-f9b6b6768b14",
      "semanticLabel":
          "Black luxury sedan with tinted windows parked in front of modern glass building",
      "capacity": "4 passengers",
      "estimatedArrival": "5 min",
      "price": "\$18.75",
      "pricePerMile": "\$3.25",
      "features": ["Leather Seats", "Wi-Fi", "Refreshments", "Premium Sound"],
      "available": true,
    },
    {
      "id": 3,
      "type": "TaxiHouse XL",
      "description": "Spacious SUVs for groups and luggage",
      "image":
          "https://images.unsplash.com/photo-1616452647790-c14899d4982b",
      "semanticLabel":
          "White SUV parked on urban street with city skyline visible in background",
      "capacity": "6 passengers",
      "estimatedArrival": "4 min",
      "price": "\$22.00",
      "pricePerMile": "\$3.80",
      "features": ["Extra Space", "Luggage Room", "Child Seats Available"],
      "available": true,
    },
    {
      "id": 4,
      "type": "TaxiHouse Eco",
      "description": "Environmentally friendly hybrid vehicles",
      "image":
          "https://images.unsplash.com/photo-1502826114304-08437d996289",
      "semanticLabel":
          "Green hybrid car parked near trees with eco-friendly design elements visible",
      "capacity": "4 passengers",
      "estimatedArrival": "6 min",
      "price": "\$10.25",
      "pricePerMile": "\$1.85",
      "features": ["Eco-Friendly", "Quiet Ride", "Low Emissions"],
      "available": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.85,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            'Choose your ride',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 32.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onVehicleSelected?.call(index);
            },
            itemCount: _vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = _vehicles[index];
              final isSelected = index == _currentIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: isSelected ? 0 : 1.h,
                ),
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  onLongPress: () => widget.onVehicleLongPress?.call(vehicle),
                  child: _buildVehicleCard(vehicle, isSelected, theme),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 1.h),
        _buildPageIndicator(theme),
      ],
    );
  }

  Widget _buildVehicleCard(
      Map<String, dynamic> vehicle, bool isSelected, ThemeData theme) {
    final isAvailable = vehicle["available"] as bool;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color:
                        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: CustomImageWidget(
                      imageUrl: vehicle["image"] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      semanticLabel: vehicle["semanticLabel"] as String,
                    ),
                  ),
                ),
              ),
              // Vehicle Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle["type"] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            vehicle["description"] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'people',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 14,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    vehicle["capacity"] as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'schedule',
                                    color: theme.colorScheme.primary,
                                    size: 14,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    vehicle["estimatedArrival"] as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            vehicle["price"] as String,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Availability overlay
          if (!isAvailable)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'block',
                        color: theme.colorScheme.error,
                        size: 32,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Currently Unavailable',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Selection indicator
          if (isSelected && isAvailable)
            Positioned(
              top: 2.w,
              right: 2.w,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomIconWidget(
                  iconName: 'check',
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _vehicles.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
