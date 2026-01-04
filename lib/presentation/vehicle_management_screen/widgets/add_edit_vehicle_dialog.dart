import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../models/vehicle_model.dart';

class AddEditVehicleDialog extends StatefulWidget {
  final VehicleModel? vehicle;
  final Function(VehicleModel) onSave;

  const AddEditVehicleDialog({
    Key? key,
    this.vehicle,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditVehicleDialog> createState() => _AddEditVehicleDialogState();
}

class _AddEditVehicleDialogState extends State<AddEditVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _priceController;
  late TextEditingController _seatsController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;

  String _selectedTransmission = 'Manual';
  String _selectedFuelType = 'Petrol';
  bool _isAvailable = true;

  final List<String> _transmissions = ['Manual', 'Automatic', 'Semi-Automatic'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.vehicle?.brand ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearController = TextEditingController(
      text: widget.vehicle?.year.toString() ?? DateTime.now().year.toString(),
    );
    _priceController = TextEditingController(
      text: widget.vehicle?.pricePerDay.toString() ?? '',
    );
    _seatsController = TextEditingController(
      text: widget.vehicle?.seats.toString() ?? '4',
    );
    _imageUrlController =
        TextEditingController(text: widget.vehicle?.imageUrl ?? '');
    _descriptionController =
        TextEditingController(text: widget.vehicle?.description ?? '');

    if (widget.vehicle != null) {
      _selectedTransmission = widget.vehicle!.transmission;
      _selectedFuelType = widget.vehicle!.fuelType;
      _isAvailable = widget.vehicle!.isAvailable;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final vehicle = VehicleModel(
        id: widget.vehicle?.id,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        pricePerDay: double.parse(_priceController.text),
        transmission: _selectedTransmission,
        seats: int.parse(_seatsController.text),
        fuelType: _selectedFuelType,
        imageUrl: _imageUrlController.text.trim(),
        isAvailable: _isAvailable,
        description: _descriptionController.text.trim(),
      );

      widget.onSave(vehicle);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 85.h),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              child: Row(
                children: [
                  Text(
                    widget.vehicle == null
                        ? 'เพิ่มรถยนต์'
                        : 'แก้ไขข้อมูลรถยนต์',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _brandController,
                        decoration: InputDecoration(
                          labelText: 'Brand *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Please enter brand'
                            : null,
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _modelController,
                        decoration: InputDecoration(
                          labelText: 'Model *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Please enter model'
                            : null,
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _yearController,
                        decoration: InputDecoration(
                          labelText: 'Year *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Please enter year';
                          final year = int.tryParse(value!);
                          if (year == null ||
                              year < 1900 ||
                              year > DateTime.now().year + 1) {
                            return 'Please enter valid year';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'ราคาต่อวัน (฿)',
                          hintText: 'กรอกราคาต่อวัน',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Please enter price';
                          final price = double.tryParse(value!);
                          if (price == null || price <= 0) {
                            return 'Please enter valid price';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTransmission,
                        decoration: InputDecoration(
                          labelText: 'Transmission *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        items: _transmissions
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedTransmission = value!),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _seatsController,
                        decoration: InputDecoration(
                          labelText: 'Number of Seats *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Please enter seats';
                          final seats = int.tryParse(value!);
                          if (seats == null || seats < 2 || seats > 12) {
                            return 'Please enter valid seats (2-12)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedFuelType,
                        decoration: InputDecoration(
                          labelText: 'Fuel Type *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        items: _fuelTypes
                            .map((f) =>
                                DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedFuelType = value!),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'Image URL *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          helperText:
                              'Enter image URL from Unsplash, Pexels, or Pixabay',
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Please enter image URL'
                            : null,
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 2.h),
                      SwitchListTile(
                        title: Text('Available for Rent'),
                        value: _isAvailable,
                        onChanged: (value) =>
                            setState(() => _isAvailable = value),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Buttons
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('ยกเลิก'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveVehicle,
                      child: Text(widget.vehicle == null ? 'เพิ่ม' : 'บันทึก'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
