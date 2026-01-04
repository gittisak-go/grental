import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EditVehicleDialog extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  final Function(Map<String, dynamic>) onSave;

  const EditVehicleDialog({
    super.key,
    required this.vehicle,
    required this.onSave,
  });

  @override
  State<EditVehicleDialog> createState() => _EditVehicleDialogState();
}

class _EditVehicleDialogState extends State<EditVehicleDialog> {
  late TextEditingController _imageController;
  late TextEditingController _typeController;
  late TextEditingController _priceController;
  late TextEditingController _pricePerMileController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _imageController = TextEditingController(
      text: widget.vehicle["image"] as String,
    );
    _typeController = TextEditingController(
      text: widget.vehicle["type"] as String,
    );

    // Convert dollar price to Thai Baht (approximate conversion: $1 = ฿35)
    final dollarPrice = widget.vehicle["price"] as String;
    final dollarValue = double.tryParse(dollarPrice.replaceAll('\$', '')) ?? 0;
    final bahtValue = (dollarValue * 35).toStringAsFixed(2);
    _priceController = TextEditingController(text: bahtValue);

    final dollarPricePerMile = widget.vehicle["pricePerMile"] as String;
    final dollarPerMileValue =
        double.tryParse(dollarPricePerMile.replaceAll('\$', '')) ?? 0;
    final bahtPerMileValue = (dollarPerMileValue * 35).toStringAsFixed(2);
    _pricePerMileController = TextEditingController(text: bahtPerMileValue);
  }

  @override
  void dispose() {
    _imageController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _pricePerMileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'แก้ไขข้อมูลรถ',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Image URL Field
                  Text(
                    'URL รูปภาพรถ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(
                      hintText: 'https://example.com/car-image.jpg',
                      prefixIcon: CustomIconWidget(
                        iconName: 'image',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอก URL รูปภาพ';
                      }
                      if (!Uri.tryParse(value)!.isAbsolute) {
                        return 'กรุณากรอก URL ที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),

                  // Vehicle Type/Brand Field
                  Text(
                    'ยี่ห้อ/รุ่นรถ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      hintText: 'เช่น RungrojCarRental Standard',
                      prefixIcon: CustomIconWidget(
                        iconName: 'directions_car',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกยี่ห้อ/รุ่นรถ';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),

                  // Price Field (Thai Baht)
                  Text(
                    'ราคา (บาทไทย)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 2.w),
                        child: Center(
                          widthFactor: 0,
                          child: Text(
                            '฿',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกราคา';
                      }
                      if (double.tryParse(value) == null) {
                        return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),

                  // Price Per Mile Field (Thai Baht)
                  Text(
                    'ราคาต่อไมล์ (บาทไทย)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _pricePerMileController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 2.w),
                        child: Center(
                          widthFactor: 0,
                          child: Text(
                            '฿',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกราคาต่อไมล์';
                      }
                      if (double.tryParse(value) == null) {
                        return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 3.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'ยกเลิก',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'บันทึก',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedVehicle = Map<String, dynamic>.from(widget.vehicle);
      updatedVehicle["image"] = _imageController.text;
      updatedVehicle["type"] = _typeController.text;
      updatedVehicle["price"] = "฿${_priceController.text}";
      updatedVehicle["pricePerMile"] = "฿${_pricePerMileController.text}";

      widget.onSave(updatedVehicle);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
