import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading:
            product.hinhanh.isNotEmpty
                ? CircleAvatar(
                  backgroundImage: NetworkImage(product.hinhanh),
                  backgroundColor: Colors.grey[200],
                )
                : CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.eco, color: Colors.green),
                ),
        title: Text(product.idsanpham),
        subtitle: Text('Loại: ${product.loaisp}'),
        // trailing: Text('ID: ${product.idsanpham}'),
        onTap: onTap,
      ),
    );
  }
}
