import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/dummy_map_widget.dart';

class MapPreviewWidget extends StatefulWidget {
  final String pickupLocation;
  final String? destinationLocation;
  final VoidCallback? onMapTap;

  const MapPreviewWidget({
    super.key,
    required this.pickupLocation,
    this.destinationLocation,
    this.onMapTap,
  });

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget> {
  DummyMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Mock coordinates for demonstration
  static const LatLng _pickupCoords = LatLng(40.7589, -73.9851); // Times Square
  static const LatLng _destinationCoords =
      LatLng(40.7505, -73.9934); // Empire State Building

  @override
  void initState() {
    super.initState();
    _setupMarkers();
    _setupRoute();
  }

  void _setupMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupCoords,
        infoWindow: InfoWindow(
          title: 'Pickup Location',
          snippet: widget.pickupLocation,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };

    if (widget.destinationLocation != null &&
        widget.destinationLocation!.isNotEmpty) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationCoords,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: widget.destinationLocation!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  void _setupRoute() {
    if (widget.destinationLocation != null &&
        widget.destinationLocation!.isNotEmpty) {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [_pickupCoords, _destinationCoords],
          color: Theme.of(context).colorScheme.primary,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };
    }
  }

  @override
  void didUpdateWidget(MapPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinationLocation != widget.destinationLocation) {
      _setupMarkers();
      _setupRoute();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            DummyMapWidget(
              onMapCreated: (DummyMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: _pickupCoords,
                zoom: 14.0,
              ),
              markers: _markers,
              polylines: _polylines,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapType: MapType.normal,
            ),
            // Glowing route effect overlay
            if (widget.destinationLocation != null &&
                widget.destinationLocation!.isNotEmpty)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            // Map controls overlay
            Positioned(
              top: 2.h,
              right: 4.w,
              child: Column(
                children: [
                  _buildMapControl(
                    icon: 'my_location',
                    onTap: () => _centerOnPickup(),
                    theme: theme,
                  ),
                  SizedBox(height: 1.h),
                  _buildMapControl(
                    icon: 'fullscreen',
                    onTap: widget.onMapTap,
                    theme: theme,
                  ),
                ],
              ),
            ),
            // Route info overlay
            if (widget.destinationLocation != null &&
                widget.destinationLocation!.isNotEmpty)
              Positioned(
                bottom: 2.h,
                left: 4.w,
                right: 4.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'directions',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2.3 miles • 8 min drive',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Fastest route available',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControl({
    required String icon,
    required VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.onSurface,
          size: 20,
        ),
      ),
    );
  }

  void _centerOnPickup() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _pickupCoords,
          zoom: 16.0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
