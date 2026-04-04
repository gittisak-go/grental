import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Required Documents Info Screen
/// Shows 4 steps: ID card, driving licence, flight ticket, bank transfer 500฿
class RequiredDocumentsScreen extends StatelessWidget {
  const RequiredDocumentsScreen({super.key});

  static const Color _bgPink = Color(0xFFFCE4EC);
  static const Color _accentPink = Color(0xFFFF2D78);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF666666);
  static const Color _cardBg = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _textDark),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'เอกสารที่ต้องใช้',
          style: GoogleFonts.notoSansThai(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Title
              _buildHeroTitle(),
              const SizedBox(height: 24),

              // Step 1 — ID Card
              _buildStepCard(
                context,
                stepNumber: 'STEP 1',
                stepColor: _accentPink,
                title: 'สำเนาบัตรประชาชน',
                subtitle: 'บัตรประชาชนของผู้เช่า - ผู้ขับ',
                imageUrl:
                    'https://images.unsplash.com/photo-1633265486064-086b219458ec?w=400&q=80',
                imageSemanticLabel:
                    'Thai national ID card with photo and personal information',
                icon: Icons.credit_card,
                iconColor: const Color(0xFF2196F3),
                isLeft: true,
              ),
              const SizedBox(height: 16),

              // Step 2 — Driving Licence
              _buildStepCard(
                context,
                stepNumber: 'STEP 2',
                stepColor: const Color(0xFFFF6B9D),
                title: 'สำเนาใบขับขี่',
                subtitle: 'ใบขับขี่ของผู้เช่า - ผู้ขับ',
                imageUrl:
                    'https://images.pixabay.com/photo/2017/08/06/12/06/people-2591874_1280.jpg',
                imageSemanticLabel:
                    'Thai private car driving licence with photo and details',
                icon: Icons.drive_eta,
                iconColor: const Color(0xFF9C27B0),
                isLeft: false,
              ),
              const SizedBox(height: 16),

              // Step 3 — Flight Ticket
              _buildStepCard(
                context,
                stepNumber: 'STEP 3',
                stepColor: _accentPink,
                title: 'ใบจองตั๋วเครื่องบิน\nขาไป - ขากลับ',
                subtitle: '( ถ้ามี )',
                imageUrl:
                    'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400&q=80',
                imageSemanticLabel:
                    'AirAsia e-ticket showing departure and return flight details',
                icon: Icons.flight,
                iconColor: const Color(0xFFFF5722),
                isLeft: true,
              ),
              const SizedBox(height: 16),

              // Step 4 — Bank Transfer
              _buildStep4BankCard(context),

              const SizedBox(height: 32),

              // Contact footer
              _buildContactFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เอกสารที่ต้องใช้',
          style: GoogleFonts.notoSansThai(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: _textDark,
            height: 1.2,
          ),
        ),
        Text(
          'ในการจองรถ',
          style: GoogleFonts.notoSansThai(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: _textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ขั้นตอนง่ายๆ สะดวกสบาย ทำตามได้ดังนี้',
          style: GoogleFonts.notoSansThai(
            fontSize: 14,
            color: _textGrey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String stepNumber,
    required Color stepColor,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String imageSemanticLabel,
    required IconData icon,
    required Color iconColor,
    required bool isLeft,
  }) {
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 130,
        height: 90,
        fit: BoxFit.cover,
        semanticLabel: imageSemanticLabel,
        errorBuilder: (_, __, ___) => Container(
          width: 130,
          height: 90,
          decoration: BoxDecoration(
            color: stepColor.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 40),
        ),
      ),
    );

    final textWidget = Expanded(
      child: Column(
        crossAxisAlignment: isLeft
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSansThai(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textDark,
              height: 1.4,
            ),
            textAlign: isLeft ? TextAlign.right : TextAlign.left,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.notoSansThai(
              fontSize: 13,
              color: _textGrey,
              fontWeight: FontWeight.w400,
            ),
            textAlign: isLeft ? TextAlign.right : TextAlign.left,
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step badge
        Align(
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: stepColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stepNumber,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: isLeft
                ? [imageWidget, const SizedBox(width: 16), textWidget]
                : [textWidget, const SizedBox(width: 16), imageWidget],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4BankCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Step badge right-aligned
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _accentPink,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'STEP 4',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: text info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ช่องทางการโอนเงิน',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ยืนยันการจองรถเช่าเพื่อทางร้านจะล็อคคิวรถคืนดังกล่าวไว้ให้ ราคา 500.- บาท',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 12,
                          color: _textGrey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right: bank info card
              Container(
                width: 160,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kasikorn logo area
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              'K',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ธนาคารกสิกรไทย',
                            style: GoogleFonts.notoSansThai(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'เลขบัญชี :',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '133 - 311234 - 1',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ชื่อบัญชี :',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'หจก.รุ่งโรจน์การชำนาญ',
                      style: GoogleFonts.notoSansThai(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE500).withAlpha(230),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '500 บาท',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1B5E20),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20).withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B5E20).withAlpha(51)),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone, color: Color(0xFF1B5E20), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ติดต่อคุณโรจน์',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                Text(
                  '086 634 8619',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00C300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'LINE',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
