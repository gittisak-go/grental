import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VehicleInfoWidget extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  const VehicleInfoWidget({
    super.key,
    required this.vehicleData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Vehicle Information',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 3.h),

          Row(
            children: [
              // Vehicle photo
              Container(
                width: 25.w,
                height: 15.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: vehicleData["photo"] as String,
                    width: 25.w,
                    height: 15.h,
                    fit: BoxFit.cover,
                    semanticLabel: vehicleData["photoSemanticLabel"] as String,
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Vehicle details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Make and model
                    Text(
                      '${vehicleData["make"]} ${vehicleData["model"]}',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 1.h),

                    // Year
                    Text(
                      vehicleData["year"].toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // License plate
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        vehicleData["licensePlate"] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Vehicle color
          Row(
            children: [
              CustomIconWidget(
                iconName: 'palette',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Color: ',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                vehicleData["color"] as String,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
