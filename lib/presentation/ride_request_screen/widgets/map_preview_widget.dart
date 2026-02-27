import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide LatLng, Marker, MarkerId, InfoWindow, CameraPosition, MapType;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

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
  GoogleMapController? _mapController;

  // Rungroj Car Rental location - Udon Thani
  static const gmaps.LatLng _businessLocation = gmaps.LatLng(17.3647, 102.8157);

  Set<gmaps.Marker> get _markers => {
    gmaps.Marker(
      markerId: const gmaps.MarkerId('business'),
      position: _businessLocation,
      infoWindow: const gmaps.InfoWindow(
        title: 'รถเช่าอุดรธานี รุ่งโรจน์คาร์เร้นท์',
        snippet: '79QPF+QQM เชียงพิน เมืองอุดรธานี',
      ),
    ),
  };

  Future<void> _openInGoogleMaps() async {
    final Uri url = Uri.parse('https://maps.app.goo.gl/n8XaHieccMdJ3VKH8');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 35.h,
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
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: const gmaps.CameraPosition(
                target: _businessLocation,
                zoom: 16.0,
              ),
              markers: _markers,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapType: gmaps.MapType.normal,
            ),
            // Open in Maps button
            Positioned(
              top: 2.h,
              right: 4.w,
              child: Column(
                children: [
                  _buildMapControl(
                    icon: 'fullscreen',
                    onTap: _openInGoogleMaps,
                    theme: theme,
                  ),
                ],
              ),
            ),
            // Location info overlay
            Positioned(
              bottom: 2.h,
              left: 4.w,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
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
                      iconName: 'location_on',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'รถเช่าอุดรธานี รุ่งโรจน์คาร์เร้นท์',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '79QPF+QQM เชียงพิน เมืองอุดรธานี',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _openInGoogleMaps,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'นำทาง',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}