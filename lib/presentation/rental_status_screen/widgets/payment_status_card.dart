import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class PaymentStatusCard extends StatelessWidget {
  final List<dynamic> payments;

  const PaymentStatusCard({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('สถานะการชำระเงิน',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 2.h),
          ...payments.map((payment) => _buildPaymentItem(payment)).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    final status = payment['payment_status'] ?? 'pending';
    final amount = payment['amount'] ?? 0.0;
    final method = _getPaymentMethodLabel(payment['payment_method']);
    final date = payment['payment_date'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_getPaymentMethodIcon(payment['payment_method']),
                      color: Colors.blue),
                  SizedBox(width: 2.w),
                  Text(method, style: TextStyle(fontSize: 12.sp)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(status).withAlpha(51),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  _getPaymentStatusLabel(status),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: _getPaymentStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('จำนวนเงิน',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              Text('฿${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ],
          ),
          if (date.isNotEmpty) ...[
            SizedBox(height: 0.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('วันที่ชำระ',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                Text(date.split('T')[0],
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String _getPaymentStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'ชำระแล้ว';
      case 'processing':
        return 'กำลังดำเนินการ';
      case 'failed':
        return 'ล้มเหลว';
      case 'refunded':
        return 'คืนเงินแล้ว';
      default:
        return 'รอชำระ';
    }
  }

  String _getPaymentMethodLabel(String? method) {
    switch (method) {
      case 'bank_transfer':
        return 'โอนเงิน';
      case 'qr_payment':
        return 'QR Code';
      case 'cash':
        return 'เงินสด';
      case 'credit_card':
        return 'บัตรเครดิต';
      default:
        return 'ไม่ระบุ';
    }
  }

  IconData _getPaymentMethodIcon(String? method) {
    switch (method) {
      case 'bank_transfer':
        return Icons.account_balance;
      case 'qr_payment':
        return Icons.qr_code;
      case 'cash':
        return Icons.money;
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }
}
