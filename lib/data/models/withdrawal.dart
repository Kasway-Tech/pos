import 'package:freezed_annotation/freezed_annotation.dart';

part 'withdrawal.freezed.dart';

@freezed
abstract class Withdrawal with _$Withdrawal {
  const factory Withdrawal({
    required String txId,
    required String toAddress,
    required double amountKas,
    required double amountIdr,
    required double kasIdrRate,
    required DateTime createdAt,
  }) = _Withdrawal;
}
