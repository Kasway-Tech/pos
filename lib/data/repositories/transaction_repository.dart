import 'package:kasway/data/models/cart_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> saveTransaction({
    required String storeId,
    required String paymentMethod,
    required List<CartItem> cartItems,
    required double totalAmount,
    double paidAmount = 0,
    double change = 0,
  }) async {
    final transaction = await _client.from('transactions').insert({
      'store_id': storeId,
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'change': change,
    }).select('id').single();

    final transactionId = transaction['id'] as String;

    final items = cartItems.map((item) {
      final additionNames = item.selectedAdditions.map((a) => a.name).join(', ');
      final displayName = additionNames.isEmpty
          ? item.product.name
          : '${item.product.name} (+$additionNames)';

      final unitPrice = item.product.price +
          item.selectedAdditions.fold<double>(0, (sum, a) => sum + a.price);

      return {
        'transaction_id': transactionId,
        'name': displayName,
        'price': unitPrice,
        'quantity': item.quantity,
        'subtotal': item.totalPrice,
      };
    }).toList();

    await _client.from('transaction_items').insert(items);
  }
}
