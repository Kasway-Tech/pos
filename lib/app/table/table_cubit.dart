import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/constants/preference_keys.dart';
import 'package:kasway/app/table/table_state.dart';
import 'package:kasway/data/models/table_item.dart';
import 'package:kasway/data/repositories/table_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TableCubit extends Cubit<TableState> {
  TableCubit({required SharedPreferences prefs, required TableRepository repo})
      : _prefs = prefs,
        _repo = repo,
        super(const TableState()) {
    _load();
  }

  final SharedPreferences _prefs;
  final TableRepository _repo;

  void _load() {
    final enabled =
        _prefs.getBool(PreferenceKeys.tableLayoutEnabled) ?? false;
    emit(state.copyWith(enabled: enabled));
    if (enabled) {
      _loadTables();
    }
  }

  Future<void> _loadTables() async {
    final tables = await _repo.getTables();
    emit(state.copyWith(tables: tables));
  }

  Future<void> setEnabled(bool value) async {
    await _prefs.setBool(PreferenceKeys.tableLayoutEnabled, value);
    emit(state.copyWith(enabled: value));
    if (value && state.tables.isEmpty) {
      await _loadTables();
    }
  }

  Future<void> saveLayout(List<TableItem> tables) async {
    await _repo.saveLayout(tables);
    emit(state.copyWith(tables: tables));
  }

  void selectTable(String? id) {
    emit(state.copyWith(selectedTableId: id));
  }

  void clearSelection() {
    emit(state.copyWith(selectedTableId: null));
  }

  Future<void> markOccupied(String id) async {
    await _repo.setOccupied(id, true);
    final updated = state.tables
        .map((t) => t.id == id ? t.copyWith(isOccupied: true) : t)
        .toList();
    emit(state.copyWith(tables: updated));
  }

  Future<void> freeTable(String? id) async {
    if (id == null) return;
    await _repo.setOccupied(id, false);
    final updated = state.tables
        .map((t) => t.id == id ? t.copyWith(isOccupied: false) : t)
        .toList();
    emit(state.copyWith(tables: updated, selectedTableId: null));
  }
}
