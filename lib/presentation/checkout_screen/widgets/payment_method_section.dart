import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class PaymentMethodSection extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String?> onMethodChanged;

  const PaymentMethodSection({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('วิธีการชำระเงิน',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 2.h),
            _buildPaymentOption(
              'bank_transfer',
              'โอนเงินผ่านธนาคาร',
              Icons.account_balance,
            ),
            _buildPaymentOption(
              'qr_payment',
              'สแกน QR Code',
              Icons.qr_code,
            ),
            _buildPaymentOption(
              'cash',
              'เงินสด (ชำระที่หน้าร้าน)',
              Icons.money,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: selectedMethod,
      onChanged: onMethodChanged,
      title: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 3.w),
          Text(label, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
      activeColor: Colors.blue,
    );
  }
}
