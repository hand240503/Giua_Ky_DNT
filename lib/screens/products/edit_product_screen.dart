import 'dart:io';

import 'package:app_giua_ky/models/product.dart';
import 'package:app_giua_ky/services/firebase_service.dart';
import 'package:app_giua_ky/services/imgur_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _typeController = TextEditingController();
  String? _imageUrl;
  File? _newImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    var productSnapshot = await _firebaseService.getProductById(
      widget.productId,
    );
    if (productSnapshot.exists) {
      Product product = Product.fromFirestore(productSnapshot);
      setState(() {
        _nameController.text = product.idsanpham;
        _priceController.text = product.gia.toString();
        _typeController.text = product.loaisp;
        _imageUrl = product.hinhanh;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _newImage = File(pickedFile.path));
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? uploadedImageUrl = _imageUrl;
      if (_newImage != null) {
        uploadedImageUrl = await ImgurService.uploadImage(_newImage!);
      }

      Product updatedProduct = Product(
        id: widget.productId,
        idsanpham: _nameController.text,
        hinhanh: uploadedImageUrl ?? '',
        gia: double.tryParse(_priceController.text) ?? 0.0,
        loaisp: _typeController.text,
      );

      await _firebaseService.updateProduct(
        widget.productId,
        updatedProduct,
        null,
        uploadedImageUrl,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã cập nhật sản phẩm thành công'),
          backgroundColor: Color(0xff0D6EFD),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật sản phẩm: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh Sửa Sản Phẩm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff0D6EFD),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),
                      const SizedBox(height: 20),
                      _buildTextField(
                        _nameController,
                        'Tên Sản Phẩm',
                        Icons.eco,
                        true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _priceController,
                        'Giá Sản Phẩm',
                        Icons.attach_money,
                        true,
                        TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _typeController,
                        'Loại',
                        Icons.category,
                        false,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Color(0xff0D6EFD),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Lưu Thay Đổi',
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh sản phẩm',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                _newImage != null
                    ? Image.file(
                      _newImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                    : (_imageUrl != null && _imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: _imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                        )
                        : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text(
                              'Chưa có ảnh',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Chọn ảnh mới'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool required, [
    TextInputType type = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xff0D6EFD)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator:
          required
              ? (value) => value!.isEmpty ? 'Không được để trống' : null
              : null,
    );
  }
}
