import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String idsanpham;
  final String loaisp;
  final double gia;
  final String hinhanh;

  Product({
    required this.id,
    required this.idsanpham,
    required this.loaisp,
    required this.gia,
    this.hinhanh = '',
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      idsanpham: data['idsanpham'] ?? '',
      loaisp: data['loaisp'] ?? '',
      gia: (data['gia'] ?? 0).toDouble(),
      hinhanh: data['hinhanh'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idsanpham': idsanpham,
      'loaisp': loaisp,
      'gia': gia,
      'hinhanh': hinhanh,
    };
  }
}
