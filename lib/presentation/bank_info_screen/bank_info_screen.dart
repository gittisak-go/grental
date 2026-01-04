import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/bank_account_model.dart';
import '../../services/bank_account_service.dart';
import './widgets/bank_account_card.dart';
import './widgets/rental_terms_section.dart';

class BankInfoScreen extends StatefulWidget {
  const BankInfoScreen({Key? key}) : super(key: key);

  @override
  State<BankInfoScreen> createState() => _BankInfoScreenState();
}

class _BankInfoScreenState extends State<BankInfoScreen> {
  final BankAccountService _bankService = BankAccountService();
  List<BankAccountModel> _bankAccounts = [];
  List<RentalTermModel> _rentalTerms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accounts = await _bankService.getActiveBankAccounts();
      final terms = await _bankService.getRentalTerms();

      setState(() {
        _bankAccounts = accounts;
        _rentalTerms = terms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข้อมูลการชำระเงิน',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red),
                        SizedBox(height: 2.h),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: Text('ลองใหม่อีกครั้ง'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_balance,
                                size: 50,
                                color: Colors.white,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'รุ่งโรจน์คาร์เร้นท์',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'โอนเงินเข้าบัญชีด้านล่างเพื่อจองรถ',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white.withAlpha(230),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bank Accounts Section
                        Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'บัญชีธนาคาร',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              ..._bankAccounts.map((account) => Padding(
                                    padding: EdgeInsets.only(bottom: 2.h),
                                    child: BankAccountCard(account: account),
                                  )),
                            ],
                          ),
                        ),

                        // Contact Section
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withAlpha(77),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  'โอนเงินแล้วส่งสลิปมาที่ Line: @rungroj หรือโทร 086-634-8619',
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Rental Terms Section
                        RentalTermsSection(rentalTerms: _rentalTerms),

                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                ),
    );
  }
}
