import 'package:kasway/data/models/branch.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BranchRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// Returns branches where the signed-in user is an active member.
  Future<List<Branch>> getBranchesForCurrentUser() async {
    final data = await _client
        .from('branches')
        .select('id, name, store_id');
    return (data as List)
        .map((row) => Branch.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
