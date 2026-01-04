import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/bank_account_model.dart';

class RentalTermsSection extends StatelessWidget {
  final List<RentalTermModel> rentalTerms;

  const RentalTermsSection({
    Key? key,
    required this.rentalTerms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highlightTerms =
        rentalTerms.where((t) => t.category == 'highlight').toList();
    final otherTerms =
        rentalTerms.where((t) => t.category != 'highlight').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Highlights Section
        if (highlightTerms.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'จุดเด่นของเรา',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withAlpha(26),
                  Theme.of(context).colorScheme.secondary.withAlpha(26),
                ],
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: highlightTerms.map((term) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              term.title,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              term.content,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 3.h),
        ],

        // Other Terms Section
        if (otherTerms.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'เงื่อนไขการเช่า',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          ...otherTerms.map((term) {
            return Container(
              margin: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForCategory(term.category),
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          term.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    term.content,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // Contact Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                Text(
                  'ติดต่อสอบถาม',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: Colors.white, size: 20),
                    SizedBox(width: 1.w),
                    Text(
                      '086-634-8619 / 096-363-8519',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat, color: Colors.white, size: 20),
                    SizedBox(width: 1.w),
                    Text(
                      'Line: @rungroj',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'payment':
        return Icons.payment;
      case 'deposit':
        return Icons.security;
      case 'fuel':
        return Icons.local_gas_station;
      case 'cancellation':
        return Icons.cancel;
      default:
        return Icons.article;
    }
  }
}
