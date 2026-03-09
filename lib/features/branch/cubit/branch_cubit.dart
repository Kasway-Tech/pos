import 'package:bloc/bloc.dart';
import 'package:kasway/data/models/branch.dart';
import 'package:kasway/data/repositories/auth_repository.dart';
import 'package:kasway/data/repositories/branch_repository.dart';
import 'package:kasway/features/branch/cubit/branch_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class BranchCubit extends Cubit<BranchState> {
  BranchCubit({
    required BranchRepository branchRepository,
    required AuthRepository authRepository,
  })  : _branchRepository = branchRepository,
        super(const BranchState()) {
    // Clear branch when user signs out
    authRepository.authStateChanges.listen((event) {
      if (event.event == sb.AuthChangeEvent.signedOut) {
        clearBranch();
      }
    });
  }

  final BranchRepository _branchRepository;

  Future<void> loadBranches() async {
    emit(state.copyWith(status: BranchStatus.loading));
    try {
      final branches = await _branchRepository.getBranchesForCurrentUser();
      emit(state.copyWith(status: BranchStatus.success, branches: branches));
    } catch (_) {
      emit(state.copyWith(status: BranchStatus.failure));
    }
  }

  void selectBranch(Branch branch) {
    emit(state.copyWith(selectedBranch: branch));
  }

  void clearBranch() {
    emit(const BranchState());
  }
}
