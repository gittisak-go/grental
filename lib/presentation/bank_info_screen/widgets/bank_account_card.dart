import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../models/bank_account_model.dart';

class BankAccountCard extends StatelessWidget {
  final BankAccountModel account;

  const BankAccountCard({
    Key? key,
    required this.account,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('คัดลอก$labelแล้ว'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Theme.of(context).colorScheme.primaryContainer.withAlpha(26),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bank Name Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    account.bankName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                if (account.accountType == 'savings')
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(51),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'ออมทรัพย์',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 2.h),

            // Account Number
            _buildInfoRow(
              context,
              icon: Icons.credit_card,
              label: 'เลขที่บัญชี',
              value: account.accountNumber,
              onCopy: () => _copyToClipboard(
                context,
                account.accountNumber,
                'เลขที่บัญชี',
              ),
            ),

            SizedBox(height: 1.5.h),

            // Account Name
            _buildInfoRow(
              context,
              icon: Icons.person,
              label: 'ชื่อบัญชี',
              value: account.accountName,
              onCopy: () => _copyToClipboard(
                context,
                account.accountName,
                'ชื่อบัญชี',
              ),
            ),

            if (account.branch != null) ...[
              SizedBox(height: 1.5.h),
              _buildInfoRow(
                context,
                icon: Icons.location_on,
                label: 'สาขา',
                value: account.branch!,
              ),
            ],

            if (account.notes != null && account.notes!.isNotEmpty) ...[
              SizedBox(height: 1.5.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        account.notes!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary.withAlpha(179),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: Icon(Icons.copy, size: 20),
            onPressed: onCopy,
            color: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.all(1.w),
            constraints: BoxConstraints(),
          ),
      ],
    );
  }
}
