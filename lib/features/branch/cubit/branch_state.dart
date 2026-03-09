import 'package:equatable/equatable.dart';
import 'package:kasway/data/models/branch.dart';

enum BranchStatus { initial, loading, success, failure }

class BranchState extends Equatable {
  const BranchState({
    this.status = BranchStatus.initial,
    this.branches = const [],
    this.selectedBranch,
  });

  final BranchStatus status;
  final List<Branch> branches;
  final Branch? selectedBranch;

  bool get hasBranchSelected => selectedBranch != null;

  BranchState copyWith({
    BranchStatus? status,
    List<Branch>? branches,
    Branch? selectedBranch,
  }) {
    return BranchState(
      status: status ?? this.status,
      branches: branches ?? this.branches,
      selectedBranch: selectedBranch ?? this.selectedBranch,
    );
  }

  @override
  List<Object?> get props => [status, branches, selectedBranch];
}
