import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: theme.colorScheme.onSurface,
            size: 5.w,
          ),
        ),
        title: Text(
          'เกี่ยวกับแอป',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header with Logo
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withAlpha(179),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'assets/images/Rungroj_Car_Rental-logo-1767574577173.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'รุ่งโรจน์คาร์เร้นท์',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Rungroj Car Rental',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withAlpha(230),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'เวอร์ชัน 1.0.0',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // App Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เกี่ยวกับเรา',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    'รุ่งโรจน์คาร์เร้นท์ คือบริการรถเช่าชั้นนำในพื้นที่อุดรธานี ให้บริการรถเช่าคุณภาพสูงพร้อมระบบการจองออนไลน์ที่ทันสมัย เหมาะสำหรับทั้งการเดินทางธุรกิจและท่องเที่ยว',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(204),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Key Features
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'คุณสมบัติเด่น',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildFeatureItem(
                    context,
                    icon: 'directions_car',
                    title: 'รถหลากหลายรุ่น',
                    description:
                        'เลือกรถเช่าได้ตามความต้องการ ตั้งแต่รถเก๋งไปจนถึง SUV',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: 'calendar_today',
                    title: 'จองออนไลน์สะดวก',
                    description: 'ระบบจองรถที่ง่ายและรวดเร็ว พร้อมยืนยันทันที',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: 'verified',
                    title: 'รถสะอาดและปลอดภัย',
                    description: 'ตรวจสอบและทำความสะอาดทุกคันก่อนส่งมอบ',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: 'support_agent',
                    title: 'บริการตลอด 24 ชั่วโมง',
                    description: 'ทีมงานพร้อมให้ความช่วยเหลือตลอดเวลา',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: 'location_on',
                    title: 'รับ-ส่งที่สนามบิน',
                    description: 'บริการรับ-ส่งที่ท่าอากาศยานนานาชาติอุดรธานี',
                  ),
                  _buildFeatureItem(
                    context,
                    icon: 'payment',
                    title: 'ชำระเงินง่าย',
                    description: 'รองรับการชำระเงินหลากหลายช่องทาง',
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Company Information
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha(51),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ข้อมูลติดต่อ',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildContactItem(
                    context,
                    icon: 'location_on',
                    title: 'ที่อยู่',
                    value:
                        '79QPF+QQM เชียงพิณ อำเภอเมืองอุดรธานี อุดรธานี 41000',
                    onTap: () => _launchMaps(),
                  ),
                  _buildContactItem(
                    context,
                    icon: 'phone',
                    title: 'โทรศัพท์',
                    value: '086 634 8619',
                    onTap: () => _launchPhone('0866348619'),
                  ),
                  _buildContactItem(
                    context,
                    icon: 'email',
                    title: 'อีเมล',
                    value: 'Patty_patteera19@hotmail.com',
                    onTap: () => _launchEmail('Patty_patteera19@hotmail.com'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Social Media Links
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ติดตามเรา',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton(
                        context,
                        icon: 'facebook',
                        label: 'Facebook',
                        color: const Color(0xFF1877F2),
                        onTap: () => _launchURL('https://facebook.com'),
                      ),
                      _buildSocialButton(
                        context,
                        icon: 'chat',
                        label: 'Line',
                        color: const Color(0xFF00B900),
                        onTap: () => _launchURL('https://line.me'),
                      ),
                      _buildSocialButton(
                        context,
                        icon: 'chat',
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        onTap: () => _launchURL('https://wa.me/66866348619'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // App Information
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
              child: Column(
                children: [
                  Text(
                    'รุ่งโรจน์คาร์เร้นท์',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'เวอร์ชัน 1.0.0 (Build 100)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '© 2026 รุ่งโรจน์คาร์เร้นท์ สงวนลิขสิทธิ์',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _showTermsDialog(context),
                        child: Text(
                          'ข้อกำหนดการใช้งาน',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Text(
                        ' • ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showPrivacyDialog(context),
                        child: Text(
                          'นโยบายความเป็นส่วนตัว',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(179),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurface.withAlpha(102),
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 28.w,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 8.w,
            ),
            SizedBox(height: 0.8.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchMaps() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/place/17.386,102.774',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch maps');
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch phone');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch email');
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ข้อกำหนดการใช้งาน'),
        content: const SingleChildScrollView(
          child: Text(
            'ข้อกำหนดและเงื่อนไขการใช้บริการรถเช่ารุ่งโรจน์คาร์เร้นท์\n\n'
            '1. ผู้เช่าต้องมีอายุไม่ต่ำกว่า 21 ปี และมีใบขับขี่ถูกต้องตามกฎหมาย\n\n'
            '2. ผู้เช่าต้องวางเงินประกันตามเงื่อนไขที่กำหนด\n\n'
            '3. ห้ามนำรถไปใช้ในกิจกรรมที่ผิดกฎหมาย\n\n'
            '4. ผู้เช่ารับผิดชอบค่าเสียหายที่เกิดขึ้นจากการใช้งาน\n\n'
            '5. ต้องคืนรถตรงเวลาตามที่ตกลง หากล่าช้าจะมีค่าปรับเพิ่มเติม',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('นโยบายความเป็นส่วนตัว'),
        content: const SingleChildScrollView(
          child: Text(
            'นโยบายความเป็นส่วนตัวของรุ่งโรจน์คาร์เร้นท์\n\n'
            'เรารักษาความเป็นส่วนตัวของข้อมูลลูกค้าอย่างเคร่งครัด\n\n'
            '1. เก็บรักษาข้อมูลส่วนบุคคลอย่างปลอดภัย\n\n'
            '2. ไม่นำข้อมูลไปเปิดเผยหรือขายให้บุคคลที่สาม\n\n'
            '3. ใช้ข้อมูลเพื่อการให้บริการและปรับปรุงคุณภาพเท่านั้น\n\n'
            '4. ลูกค้ามีสิทธิ์เข้าถึงและขอลบข้อมูลได้ตามกฎหมาย',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}
