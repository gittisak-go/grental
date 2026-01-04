import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DriverHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> driverData;
  final VoidCallback onClose;

  const DriverHeaderWidget({
    super.key,
    required this.driverData,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 35.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Close button
          Positioned(
            top: 8.h,
            right: 4.w,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),

          // Centered content with framed driver photo
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                // Framed driver photo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(1.w),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(1.5.w),
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                theme.colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CustomImageWidget(
                          imageUrl: driverData["photo"] as String,
                          width: 28.w,
                          height: 28.w,
                          fit: BoxFit.cover,
                          semanticLabel:
                              driverData["photoSemanticLabel"] as String,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Driver name
                Text(
                  driverData["name"] as String,
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 1.h),

                // Rating and verification badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rating
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.2.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            driverData["rating"].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Verification badges
                    if (driverData["isVerified"] == true) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successLight,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.successLight.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'verified',
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Verified',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (driverData["isProfessional"] == true) ...[
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.secondary
                                  .withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Pro',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
