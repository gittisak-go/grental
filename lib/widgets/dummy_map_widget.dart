import 'dart:math' as math;
import 'package:flutter/material.dart';

// Mock classes to replace Google Maps types
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LatLng &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

class CameraPosition {
  final LatLng target;
  final double zoom;
  final double bearing;
  final double tilt;

  const CameraPosition({
    required this.target,
    this.zoom = 10.0,
    this.bearing = 0.0,
    this.tilt = 0.0,
  });
}

class CameraUpdate {
  final CameraPosition? _position;
  final LatLngBounds? _bounds;
  final double? _padding;

  CameraUpdate._(this._position, this._bounds, this._padding);

  static CameraUpdate newCameraPosition(CameraPosition cameraPosition) {
    return CameraUpdate._(cameraPosition, null, null);
  }

  static CameraUpdate newLatLngZoom(LatLng target, double zoom) {
    return CameraUpdate._(
      CameraPosition(target: target, zoom: zoom),
      null,
      null,
    );
  }

  static CameraUpdate newLatLngBounds(LatLngBounds bounds, double padding) {
    return CameraUpdate._(null, bounds, padding);
  }
}

class LatLngBounds {
  final LatLng southwest;
  final LatLng northeast;

  const LatLngBounds({
    required this.southwest,
    required this.northeast,
  });
}

class MarkerId {
  final String value;
  const MarkerId(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkerId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class InfoWindow {
  final String? title;
  final String? snippet;

  const InfoWindow({this.title, this.snippet});
}

class BitmapDescriptor {
  static const double hueRed = 0.0;
  static const double hueBlue = 240.0;
  static const double hueYellow = 60.0;
  static const double hueGreen = 120.0;

  static BitmapDescriptor defaultMarkerWithHue(double hue) {
    return BitmapDescriptor._internal(hue);
  }

  final double _hue;
  const BitmapDescriptor._internal(this._hue);

  Color get color {
    return HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor();
  }
}

class Marker {
  final MarkerId markerId;
  final LatLng position;
  final BitmapDescriptor icon;
  final InfoWindow infoWindow;
  final double rotation;
  final VoidCallback? onTap;

  const Marker({
    required this.markerId,
    required this.position,
    this.icon = const BitmapDescriptor._internal(0.0),
    this.infoWindow = const InfoWindow(),
    this.rotation = 0.0,
    this.onTap,
  });
}

class PolylineId {
  final String value;
  const PolylineId(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PolylineId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class PatternItem {
  final double length;
  final bool isDash;

  const PatternItem._(this.length, this.isDash);

  static PatternItem dash(double length) => PatternItem._(length, true);
  static PatternItem gap(double length) => PatternItem._(length, false);
}

class Polyline {
  final PolylineId polylineId;
  final List<LatLng> points;
  final Color color;
  final int width;
  final List<PatternItem> patterns;

  const Polyline({
    required this.polylineId,
    required this.points,
    this.color = Colors.blue,
    this.width = 1,
    this.patterns = const [],
  });
}

enum MapType { normal, satellite, terrain, hybrid }

typedef MapCreatedCallback = void Function(DummyMapController controller);

class DummyMapController {
  final _DummyMapWidgetState _state;

  DummyMapController._(this._state);

  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    await _state._animateCamera(cameraUpdate);
  }

  void dispose() {
    // Cleanup if needed
  }
}

class DummyMapWidget extends StatefulWidget {
  final MapCreatedCallback? onMapCreated;
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;
  final bool compassEnabled;
  final bool trafficEnabled;
  final bool buildingsEnabled;
  final MapType mapType;
  final String? style;

  const DummyMapWidget({
    super.key,
    this.onMapCreated,
    required this.initialCameraPosition,
    this.markers = const {},
    this.polylines = const {},
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
    this.zoomControlsEnabled = true,
    this.mapToolbarEnabled = true,
    this.compassEnabled = true,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.mapType = MapType.normal,
    this.style,
  });

  @override
  State<DummyMapWidget> createState() => _DummyMapWidgetState();
}

class _DummyMapWidgetState extends State<DummyMapWidget>
    with TickerProviderStateMixin {
  late CameraPosition _cameraPosition;
  late AnimationController _animationController;
  late DummyMapController _controller;

  // Pan and zoom state
  Offset _panOffset = Offset.zero;
  double _currentZoom = 10.0;
  bool _isPanning = false;

  @override
  void initState() {
    super.initState();
    _cameraPosition = widget.initialCameraPosition;
    _currentZoom = widget.initialCameraPosition.zoom;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _controller = DummyMapController._(this);

    // Call onMapCreated callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMapCreated?.call(_controller);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _animateCamera(CameraUpdate cameraUpdate) async {
    if (cameraUpdate._position != null) {
      setState(() {
        _cameraPosition = cameraUpdate._position;
        _currentZoom = cameraUpdate._position.zoom;
        _panOffset = Offset.zero;
      });
    } else if (cameraUpdate._bounds != null) {
      // Fit to bounds logic - center and zoom to show all bounds
      final bounds = cameraUpdate._bounds;
      final centerLat =
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      final centerLng =
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2;

      setState(() {
        _cameraPosition = CameraPosition(
          target: LatLng(centerLat, centerLng),
          zoom: 12.0, // Reasonable zoom for bounds
        );
        _currentZoom = 12.0;
        _panOffset = Offset.zero;
      });
    }

    // Animate the change
    await _animationController.forward(from: 0);
  }

  // Convert LatLng to screen coordinates
  Offset _latLngToScreenPoint(LatLng latLng, Size mapSize) {
    // Simple mercator-like projection
    final centerLat = _cameraPosition.target.latitude;
    final centerLng = _cameraPosition.target.longitude;

    // Scale based on zoom level
    final scale = math.pow(2, _currentZoom - 10) * 100;

    final deltaLng = (latLng.longitude - centerLng) * scale;
    final deltaLat = (centerLat - latLng.latitude) *
        scale; // Inverted for screen coordinates

    return Offset(
      mapSize.width / 2 + deltaLng + _panOffset.dx,
      mapSize.height / 2 + deltaLat + _panOffset.dy,
    );
  }

  // Convert screen point to LatLng
  LatLng _screenPointToLatLng(Offset point, Size mapSize) {
    final centerLat = _cameraPosition.target.latitude;
    final centerLng = _cameraPosition.target.longitude;

    final scale = math.pow(2, _currentZoom - 10) * 100;

    final deltaX = point.dx - mapSize.width / 2 - _panOffset.dx;
    final deltaY = point.dy - mapSize.height / 2 - _panOffset.dy;

    final deltaLng = deltaX / scale;
    final deltaLat = -deltaY / scale; // Inverted for screen coordinates

    return LatLng(centerLat + deltaLat, centerLng + deltaLng);
  }

  void _onPanStart(DragStartDetails details) {
    _isPanning = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isPanning) {
      setState(() {
        _panOffset += details.delta;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _isPanning = false;

    // Update camera position to reflect the pan
    final mapSize = MediaQuery.of(context).size;
    final newCenter = _screenPointToLatLng(
      Offset(mapSize.width / 2, mapSize.height / 2),
      mapSize,
    );

    setState(() {
      _cameraPosition = CameraPosition(
        target: newCenter,
        zoom: _currentZoom,
      );
      _panOffset = Offset.zero;
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    _isPanning = true;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_isPanning) {
      // Handle zoom
      final newZoom = (_currentZoom * details.scale).clamp(3.0, 20.0);

      setState(() {
        _currentZoom = newZoom;
        _panOffset += details.focalPointDelta;
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _isPanning = false;

    // Update camera position
    final mapSize = MediaQuery.of(context).size;
    final newCenter = _screenPointToLatLng(
      Offset(mapSize.width / 2, mapSize.height / 2),
      mapSize,
    );

    setState(() {
      _cameraPosition = CameraPosition(
        target: newCenter,
        zoom: _currentZoom,
      );
      _panOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1a1a2e),
                        const Color(0xFF16213e),
                        const Color(0xFF0f3460),
                      ]
                    : [
                        const Color(0xFFe3f2fd),
                        const Color(0xFFbbdefb),
                        const Color(0xFF90caf9),
                      ],
              ),
            ),
            child: CustomPaint(
              painter: DummyMapPainter(
                cameraPosition: _cameraPosition,
                currentZoom: _currentZoom,
                panOffset: _panOffset,
                markers: widget.markers,
                polylines: widget.polylines,
                mapSize: mapSize,
                isDark: isDark,
              ),
              size: mapSize,
            ),
          ),
        );
      },
    );
  }
}

class DummyMapPainter extends CustomPainter {
  final CameraPosition cameraPosition;
  final double currentZoom;
  final Offset panOffset;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Size mapSize;
  final bool isDark;

  DummyMapPainter({
    required this.cameraPosition,
    required this.currentZoom,
    required this.panOffset,
    required this.markers,
    required this.polylines,
    required this.mapSize,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid pattern to simulate map tiles
    _drawMapGrid(canvas, size);

    // Draw street-like patterns
    _drawStreets(canvas, size);

    // Draw polylines
    _drawPolylines(canvas, size);

    // Draw markers
    _drawMarkers(canvas, size);
  }

  void _drawMapGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          (isDark ? Colors.white : Colors.grey.shade300).withValues(alpha: 0.3)
      ..strokeWidth = 1;

    final gridSize = (math.pow(2, currentZoom - 8) * 20).toDouble();

    // Draw vertical lines
    for (double x = -gridSize; x < size.width + gridSize; x += gridSize) {
      final adjustedX = x + (panOffset.dx % gridSize);
      canvas.drawLine(
        Offset(adjustedX, 0),
        Offset(adjustedX, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = -gridSize; y < size.height + gridSize; y += gridSize) {
      final adjustedY = y + (panOffset.dy % gridSize);
      canvas.drawLine(
        Offset(0, adjustedY),
        Offset(size.width, adjustedY),
        paint,
      );
    }
  }

  void _drawStreets(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.grey.shade700 : Colors.grey.shade400
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw some fake streets based on camera position and zoom
    final streetSpacing = math.pow(2, currentZoom - 6) * 30;
    final random = math.Random(42); // Fixed seed for consistent streets

    for (int i = 0; i < 20; i++) {
      final startX = random.nextDouble() * size.width * 2 - size.width / 2;
      final startY = random.nextDouble() * size.height * 2 - size.height / 2;
      final endX = startX + (random.nextDouble() - 0.5) * streetSpacing;
      final endY = startY + (random.nextDouble() - 0.5) * streetSpacing;

      canvas.drawLine(
        Offset(startX + panOffset.dx, startY + panOffset.dy),
        Offset(endX + panOffset.dx, endY + panOffset.dy),
        paint,
      );
    }
  }

  void _drawPolylines(Canvas canvas, Size size) {
    for (final polyline in polylines) {
      if (polyline.points.length < 2) continue;

      final paint = Paint()
        ..color = polyline.color
        ..strokeWidth = polyline.width.toDouble()
        ..strokeCap = StrokeCap.round;

      // Handle dashed lines
      if (polyline.patterns.isNotEmpty) {
        paint.strokeWidth = polyline.width.toDouble();
        // Simple dashed line implementation
        _drawDashedPolyline(canvas, polyline, paint);
      } else {
        final path = Path();
        bool first = true;

        for (final point in polyline.points) {
          final screenPoint = _latLngToScreenPoint(point, size);

          if (first) {
            path.moveTo(screenPoint.dx, screenPoint.dy);
            first = false;
          } else {
            path.lineTo(screenPoint.dx, screenPoint.dy);
          }
        }

        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawDashedPolyline(Canvas canvas, Polyline polyline, Paint paint) {
    for (int i = 0; i < polyline.points.length - 1; i++) {
      final start = _latLngToScreenPoint(polyline.points[i], mapSize);
      final end = _latLngToScreenPoint(polyline.points[i + 1], mapSize);

      _drawDashedLine(canvas, start, end, paint, polyline.patterns);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint,
      List<PatternItem> patterns) {
    final distance = (end - start).distance;
    final direction = (end - start) / distance;

    double currentDistance = 0;
    int patternIndex = 0;
    bool drawing = true;

    while (currentDistance < distance) {
      final pattern = patterns[patternIndex % patterns.length];
      final segmentLength =
          math.min(pattern.length, distance - currentDistance);

      final segmentStart = start + direction * currentDistance;
      final segmentEnd = start + direction * (currentDistance + segmentLength);

      if (drawing && pattern.isDash) {
        canvas.drawLine(segmentStart, segmentEnd, paint);
      }

      currentDistance += segmentLength;
      drawing = !drawing;
      patternIndex++;
    }
  }

  void _drawMarkers(Canvas canvas, Size size) {
    for (final marker in markers) {
      final screenPoint = _latLngToScreenPoint(marker.position, size);

      // Skip if marker is outside visible area
      if (screenPoint.dx < -50 ||
          screenPoint.dx > size.width + 50 ||
          screenPoint.dy < -50 ||
          screenPoint.dy > size.height + 50) {
        continue;
      }

      _drawMarker(canvas, screenPoint, marker);
    }
  }

  void _drawMarker(Canvas canvas, Offset position, Marker marker) {
    final markerSize = 20.0 * (currentZoom / 15.0).clamp(0.5, 2.0);

    // Draw marker shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(
      position + const Offset(2, 2),
      markerSize + 2,
      shadowPaint,
    );

    // Draw marker body
    final markerPaint = Paint()
      ..color = marker.icon.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, markerSize, markerPaint);

    // Draw marker border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, markerSize, borderPaint);

    // Draw marker icon (simplified)
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, markerSize * 0.4, iconPaint);
  }

  Offset _latLngToScreenPoint(LatLng latLng, Size mapSize) {
    final centerLat = cameraPosition.target.latitude;
    final centerLng = cameraPosition.target.longitude;

    final scale = math.pow(2, currentZoom - 10) * 100;

    final deltaLng = (latLng.longitude - centerLng) * scale;
    final deltaLat = (centerLat - latLng.latitude) * scale;

    return Offset(
      mapSize.width / 2 + deltaLng + panOffset.dx,
      mapSize.height / 2 + deltaLat + panOffset.dy,
    );
  }

  @override
  bool shouldRepaint(DummyMapPainter oldDelegate) {
    return oldDelegate.cameraPosition != cameraPosition ||
        oldDelegate.currentZoom != currentZoom ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.markers != markers ||
        oldDelegate.polylines != polylines;
  }
}