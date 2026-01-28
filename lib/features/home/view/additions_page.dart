import 'package:atomikpos/data/models/addition.dart';
import 'package:atomikpos/data/models/product.dart';
import 'package:atomikpos/features/home/view/widgets/additions_side_view.dart';
import 'package:flutter/material.dart';

class AdditionsPage extends StatelessWidget {
  const AdditionsPage({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  final Product product;
  final void Function(List<Addition> selectedAdditions) onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdditionsSideView(
        product: product,
        onConfirm: onConfirm,
        onBack: () => Navigator.of(context).pop(),
      ),
    );
  }
}
