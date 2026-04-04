import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './edit_vehicle_dialog.dart';

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

  // Updated with real Rungroj Car Rental fleet — 12 vehicles, Thai Baht prices
  List<Map<String, dynamic>> _vehicles = [
    {
      "id": 1,
      "type": "City Turbo",
      "description": "รถเก๋งขนาดกลาง เหมาะสำหรับการเดินทางในเมือง",
      "image":
          "https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg",
      "semanticLabel": "Silver city sedan car parked on urban street",
      "capacity": "4 ที่นั่ง",
      "estimatedArrival": "3 นาที",
      "price": "฿1,000/วัน",
      "pricePerDay": 1000.0,
      "features": ["เครื่องปรับอากาศ", "ระบบเสียง", "ที่ชาร์จโทรศัพท์"],
      "available": true,
    },
    {
      "id": 2,
      "type": "New Yaris Sport",
      "description": "รถเก๋งสปอร์ต ประหยัดน้ำมัน ขับสนุก",
      "image":
          "https://images.pexels.com/photos/1592384/pexels-photo-1592384.jpeg",
      "semanticLabel": "White compact sport hatchback car on road",
      "capacity": "4 ที่นั่ง",
      "estimatedArrival": "4 นาที",
      "price": "฿800/วัน",
      "pricePerDay": 800.0,
      "features": ["เครื่องปรับอากาศ", "ระบบเสียง", "ประหยัดน้ำมัน"],
      "available": true,
    },
    {
      "id": 3,
      "type": "New Yaris Ativ",
      "description": "รถเก๋งซีดาน สะดวกสบาย เหมาะสำหรับครอบครัว",
      "image":
          "https://images.pexels.com/photos/3729464/pexels-photo-3729464.jpeg",
      "semanticLabel": "White sedan car parked in parking lot",
      "capacity": "4 ที่นั่ง",
      "estimatedArrival": "5 นาที",
      "price": "฿1,000/วัน",
      "pricePerDay": 1000.0,
      "features": ["เครื่องปรับอากาศ", "ระบบเสียง", "ที่ชาร์จโทรศัพท์"],
      "available": true,
    },
    {
      "id": 4,
      "type": "Almera Sportech",
      "description": "รถเก๋งสปอร์ตเทค ดีไซน์ทันสมัย",
      "image":
          "https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg",
      "semanticLabel": "Gray sporty sedan car on city road",
      "capacity": "4 ที่นั่ง",
      "estimatedArrival": "4 นาที",
      "price": "฿800/วัน",
      "pricePerDay": 800.0,
      "features": ["เครื่องปรับอากาศ", "ระบบเสียง", "ที่ชาร์จโทรศัพท์"],
      "available": true,
    },
    {
      "id": 5,
      "type": "Ciaz",
      "description": "รถเก๋งซีดานหรู กว้างขวาง นุ่มนวล",
      "image":
          "https://images.pexels.com/photos/210019/pexels-photo-210019.jpeg",
      "semanticLabel": "Silver luxury sedan car parked on street",
      "capacity": "4 ที่นั่ง",
      "estimatedArrival": "5 นาที",
      "price": "฿800/วัน",
      "pricePerDay": 800.0,
      "features": ["เครื่องปรับอากาศ", "ระบบเสียง", "เบาะหนัง"],
      "available": true,
    },
    {
      "id": 6,
      "type": "Ranger Raptor",
      "description": "กระบะสมรรถนะสูง แข็งแกร่ง เหมาะทุกเส้นทาง",
      "image":
          "https://images.pexels.com/photos/1638459/pexels-photo-1638459.jpeg",
      "semanticLabel": "Black pickup truck on off-road terrain",
      "capacity": "4 ที่นั่ง",
      "estimatedArrival": "6 นาที",
      "price": "฿2,500/วัน",
      "pricePerDay": 2500.0,
      "features": ["4WD", "เครื่องปรับอากาศ", "ระบบเสียง"],
      "available": true,
    },
    {
      "id": 7,
      "type": "Vigo Champ",
      "description": "กระบะคลาสสิก ทนทาน เชื่อถือได้",
      "image":
          "https://images.pexels.com/photos/2533092/pexels-photo-2533092.jpeg",
      "semanticLabel": "White pickup truck parked on dirt road",
      "capacity": "4 ที่นั่ง",
      "estimatedArrival": "5 นาที",
      "price": "฿2,000/วัน",
      "pricePerDay": 2000.0,
      "features": ["เครื่องปรับอากาศ", "ระบบเสียง", "ทนทาน"],
      "available": true,
    },
    {
      "id": 8,
      "type": "Veloz",
      "description": "MPV อเนกประสงค์ กว้างขวาง เหมาะครอบครัว",
      "image":
          "https://images.pexels.com/photos/1007410/pexels-photo-1007410.jpeg",
      "semanticLabel": "Silver MPV minivan parked in suburban area",
      "capacity": "7 ที่นั่ง",
      "estimatedArrival": "4 นาที",
      "price": "฿1,800/วัน",
      "pricePerDay": 1800.0,
      "features": ["เครื่องปรับอากาศ", "7 ที่นั่ง", "ระบบเสียง"],
      "available": true,
    },
    {
      "id": 9,
      "type": "Pajero Sport Elite",
      "description": "SUV พรีเมียม ทรงพลัง หรูหรา",
      "image":
          "https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg",
      "semanticLabel": "Black premium SUV on mountain road",
      "capacity": "7 ที่นั่ง",
      "estimatedArrival": "7 นาที",
      "price": "฿2,200/วัน",
      "pricePerDay": 2200.0,
      "features": ["4WD", "เบาะหนัง", "ระบบเสียงพรีเมียม"],
      "available": true,
    },
    {
      "id": 10,
      "type": "Cross",
      "description": "SUV ขนาดกลาง ทันสมัย ประหยัดน้ำมัน",
      "image":
          "https://images.pexels.com/photos/1592384/pexels-photo-1592384.jpeg",
      "semanticLabel": "White crossover SUV on city road",
      "capacity": "5 ที่นั่ง",
      "estimatedArrival": "4 นาที",
      "price": "฿1,800/วัน",
      "pricePerDay": 1800.0,
      "features": ["เครื่องปรับอากาศ", "ระบบเสียง", "ที่ชาร์จโทรศัพท์"],
      "available": true,
    },
    {
      "id": 11,
      "type": "Xpander",
      "description": "MPV อเนกประสงค์ ดีไซน์สปอร์ต",
      "image":
          "https://images.pexels.com/photos/3729464/pexels-photo-3729464.jpeg",
      "semanticLabel": "Silver MPV crossover parked in urban area",
      "capacity": "7 ที่นั่ง",
      "estimatedArrival": "5 นาที",
      "price": "฿1,800/วัน",
      "pricePerDay": 1800.0,
      "features": ["เครื่องปรับอากาศ", "7 ที่นั่ง", "ระบบเสียง"],
      "available": true,
    },
    {
      "id": 12,
      "type": "MU-X",
      "description": "SUV 7 ที่นั่ง ทรงพลัง เหมาะทุกเส้นทาง",
      "image":
          "https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg",
      "semanticLabel": "Dark gray large SUV on highway",
      "capacity": "7 ที่นั่ง",
      "estimatedArrival": "6 นาที",
      "price": "฿1,990/วัน",
      "pricePerDay": 1990.0,
      "features": ["4WD", "เครื่องปรับอากาศ", "7 ที่นั่ง"],
      "available": true,
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
            'เลือกประเภทรถของคุณ',
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
                  child: _buildVehicleCard(vehicle, isSelected, theme, index),
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
    Map<String, dynamic> vehicle,
    bool isSelected,
    ThemeData theme,
    int index,
  ) {
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
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
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
          // Edit button
          Positioned(
            top: 2.w,
            left: 2.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showEditDialog(vehicle, index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomIconWidget(
                    iconName: 'edit',
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> vehicle, int index) {
    showDialog(
      context: context,
      builder: (context) => EditVehicleDialog(
        vehicle: vehicle,
        onSave: (updatedVehicle) {
          setState(() {
            _vehicles[index] = updatedVehicle;
          });
        },
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
