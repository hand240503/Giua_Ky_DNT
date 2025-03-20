import 'dart:io';

import 'package:app_giua_ky/models/product.dart';
import 'package:app_giua_ky/services/firebase_service.dart';
import 'package:app_giua_ky/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateImage(File file) {
    setState(() => _imageFile = file);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Product product = Product(
        id: '',
        idsanpham: _nameController.text,
        gia: double.tryParse(_priceController.text) ?? 0,
        loaisp: _typeController.text,
        hinhanh: '',
      );

      await _firebaseService.addProduct(product, _imageFile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sản Phẩm đã được lưu thành công'),
          backgroundColor: const Color(0xff0D6EFD),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu sản phảm: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm Sản Phẩm Mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff0D6EFD),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0D6EFD)),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ImagePickerWidget(
                            imageFile: _imageFile,
                            onImagePicked: _updateImage,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        _nameController,
                        'Tên Sản Phẩm',
                        Icons.shopping_bag,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Vui lòng nhập tên' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _typeController,
                        'Loại Sản Phẩm',
                        Icons.category,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Vui lòng nhập loại' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _priceController,
                        'Giá Sản Phẩm',
                        Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Vui lòng nhập giá' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xff0D6EFD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Lưu Sản Phẩm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xff0D6EFD)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
