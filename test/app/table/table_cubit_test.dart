import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/constants/preference_keys.dart';
import 'package:kasway/app/table/table_cubit.dart';
import 'package:kasway/app/table/table_state.dart';
import 'package:kasway/data/models/table_item.dart';
import 'package:kasway/data/repositories/table_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTableRepository extends Mock implements TableRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _tableA = TableItem(
  id: 'a',
  label: '1',
  seats: 4,
  x: 100,
  y: 100,
);

const _tableB = TableItem(
  id: 'b',
  label: '2',
  seats: 2,
  x: 200,
  y: 200,
);

/// Returns a fresh repository mock that returns [tables] from getTables().
MockTableRepository _repoReturning(List<TableItem> tables) {
  final repo = MockTableRepository();
  when(() => repo.getTables()).thenAnswer((_) async => tables);
  when(() => repo.saveLayout(any())).thenAnswer((_) async {});
  return repo;
}

void main() {
  group('TableCubit', () {
    late SharedPreferences prefs;
    late MockTableRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = _repoReturning([]);
    });

    TableCubit buildCubit() => TableCubit(prefs: prefs, repo: repo);

    // ── Initial state ────────────────────────────────────────────────────────

    group('initial state', () {
      test('enabled defaults to false when prefs are empty', () {
        final cubit = buildCubit();
        expect(cubit.state.enabled, isFalse);
        cubit.close();
      });

      test('tables defaults to empty list when prefs are empty', () {
        final cubit = buildCubit();
        expect(cubit.state.tables, isEmpty);
        cubit.close();
      });

      test('selectedTableId defaults to null when prefs are empty', () {
        final cubit = buildCubit();
        expect(cubit.state.selectedTableId, isNull);
        cubit.close();
      });
    });

    // ── _load — reads pref and conditionally loads tables ───────────────────

    group('_load — tableLayoutEnabled=false', () {
      test('emits enabled=false and does not call getTables', () async {
        final cubit = buildCubit();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cubit.state.enabled, isFalse);
        verifyNever(() => repo.getTables());
        await cubit.close();
      });
    });

    group('_load — tableLayoutEnabled=true', () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({
          PreferenceKeys.tableLayoutEnabled: true,
        });
        prefs = await SharedPreferences.getInstance();
        repo = _repoReturning([_tableA, _tableB]);
      });

      blocTest<TableCubit, TableState>(
        'emits at least one state with enabled=true and two tables loaded',
        build: () => TableCubit(prefs: prefs, repo: repo),
        wait: const Duration(milliseconds: 50),
        // The cubit may emit one or two states depending on async scheduling.
        // What matters is that the final state has enabled=true and 2 tables.
        verify: (cubit) {
          expect(cubit.state.enabled, isTrue);
          expect(cubit.state.tables, hasLength(2));
        },
      );

      blocTest<TableCubit, TableState>(
        '_loadTables resets isOccupied and isServed to false on all loaded tables',
        setUp: () async {
          // Simulate tables stored with dirty occupied/served state
          final dirtyTables = [
            _tableA.copyWith(isOccupied: true, isServed: true),
            _tableB.copyWith(isOccupied: true, isServed: false),
          ];
          repo = _repoReturning(dirtyTables);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          final tables = cubit.state.tables;
          expect(tables, hasLength(2));
          expect(tables.every((t) => !t.isOccupied), isTrue,
              reason: 'isOccupied must be reset to false');
          expect(tables.every((t) => !t.isServed), isTrue,
              reason: 'isServed must be reset to false');
        },
      );
    });

    // ── setEnabled ───────────────────────────────────────────────────────────

    group('setEnabled', () {
      blocTest<TableCubit, TableState>(
        'setEnabled(true) persists and emits enabled=true',
        build: buildCubit,
        act: (cubit) => cubit.setEnabled(true),
        verify: (cubit) {
          expect(cubit.state.enabled, isTrue);
          expect(prefs.getBool(PreferenceKeys.tableLayoutEnabled), isTrue);
        },
      );

      blocTest<TableCubit, TableState>(
        'setEnabled(true) calls _loadTables when tables are empty',
        setUp: () {
          repo = _repoReturning([_tableA]);
        },
        build: buildCubit,
        act: (cubit) => cubit.setEnabled(true),
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          verify(() => repo.getTables()).called(1);
          expect(cubit.state.tables, hasLength(1));
        },
      );

      blocTest<TableCubit, TableState>(
        'setEnabled(true) does NOT call _loadTables when tables already loaded',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([_tableA, _tableB]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        // Wait for initial _loadTables to finish, THEN call setEnabled(true)
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.setEnabled(true);
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          // getTables was called exactly once (from the constructor _load path)
          verify(() => repo.getTables()).called(1);
          expect(cubit.state.tables, hasLength(2));
        },
      );

      blocTest<TableCubit, TableState>(
        'setEnabled(false) persists and emits enabled=false without calling _loadTables',
        build: buildCubit,
        act: (cubit) => cubit.setEnabled(false),
        verify: (cubit) {
          expect(cubit.state.enabled, isFalse);
          expect(prefs.getBool(PreferenceKeys.tableLayoutEnabled), isFalse);
          verifyNever(() => repo.getTables());
        },
      );
    });

    // ── selectTable ──────────────────────────────────────────────────────────

    group('selectTable', () {
      blocTest<TableCubit, TableState>(
        'selectTable(id) marks the matching table isOccupied=true, isServed=false, and sets selectedTableId',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([_tableA, _tableB]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          cubit.selectTable('a');
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          final selected = cubit.state.tables.firstWhere((t) => t.id == 'a');
          expect(selected.isOccupied, isTrue);
          expect(selected.isServed, isFalse);
          expect(cubit.state.selectedTableId, 'a');
        },
      );

      blocTest<TableCubit, TableState>(
        'selectTable(id) does not modify other tables',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([_tableA, _tableB]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          cubit.selectTable('a');
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          final other = cubit.state.tables.firstWhere((t) => t.id == 'b');
          expect(other.isOccupied, isFalse);
          expect(other.isServed, isFalse);
        },
      );

      blocTest<TableCubit, TableState>(
        'selectTable(null) only clears selectedTableId, does not touch tables list',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([_tableA.copyWith(isOccupied: true)]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          // First select a table, then call selectTable(null)
          cubit.selectTable('a');
          cubit.selectTable(null);
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.selectedTableId, isNull);
          // The table that was marked occupied should remain occupied
          final tableA = cubit.state.tables.firstWhere((t) => t.id == 'a');
          expect(tableA.isOccupied, isTrue,
              reason: 'selectTable(null) must not change table occupation status');
        },
      );
    });

    // ── markServed ───────────────────────────────────────────────────────────

    group('markServed', () {
      blocTest<TableCubit, TableState>(
        'markServed(id) sets isServed=true on the matching table',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([
            _tableA.copyWith(isOccupied: true, isServed: false),
            _tableB,
          ]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          cubit.markServed('a');
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          final served = cubit.state.tables.firstWhere((t) => t.id == 'a');
          expect(served.isServed, isTrue);
        },
      );

      blocTest<TableCubit, TableState>(
        'markServed(id) leaves other tables untouched',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          // _loadTables resets isOccupied/isServed to false regardless of repo
          // values. We load bare tables and occupy both via selectTable.
          repo = _repoReturning([_tableA, _tableB]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          cubit.selectTable('a'); // isOccupied=true on 'a'
          cubit.selectTable('b'); // isOccupied=true on 'b'
          // Mark only 'a' as served; 'b' should remain isServed=false
          cubit.markServed('a');
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          final other = cubit.state.tables.firstWhere((t) => t.id == 'b');
          expect(other.isServed, isFalse,
              reason: 'markServed(a) must not change table b served status');
          expect(other.isOccupied, isTrue,
              reason: 'markServed(a) must not change table b occupied status');
        },
      );

      blocTest<TableCubit, TableState>(
        'markServed does not change selectedTableId',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([_tableA.copyWith(isOccupied: true)]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          cubit.selectTable('a');
          cubit.markServed('a');
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.selectedTableId, 'a');
        },
      );
    });

    // ── freeTable ────────────────────────────────────────────────────────────

    group('freeTable', () {
      blocTest<TableCubit, TableState>(
        'freeTable(id) sets isOccupied=false and isServed=false on matching table',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([
            _tableA.copyWith(isOccupied: true, isServed: true),
            _tableB,
          ]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          cubit.freeTable('a');
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          final freed = cubit.state.tables.firstWhere((t) => t.id == 'a');
          expect(freed.isOccupied, isFalse);
          expect(freed.isServed, isFalse);
        },
      );

      blocTest<TableCubit, TableState>(
        'freeTable(id) clears selectedTableId',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([_tableA.copyWith(isOccupied: true)]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          cubit.selectTable('a');
          cubit.freeTable('a');
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.selectedTableId, isNull);
        },
      );

      blocTest<TableCubit, TableState>(
        'freeTable(id) does not modify other tables',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          // _loadTables resets isOccupied/isServed to false regardless of what
          // the repo returns. We load bare tables and then occupy both via the
          // cubit's own methods (selectTable, markServed) to set up the test
          // precondition.
          repo = _repoReturning([_tableA, _tableB]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          // Wait for initial load
          await Future<void>.delayed(const Duration(milliseconds: 50));
          // Occupy both tables
          cubit.selectTable('a'); // isOccupied=true on 'a'
          cubit.selectTable('b'); // isOccupied=true on 'b'
          cubit.markServed('a');  // isServed=true on 'a'
          cubit.markServed('b');  // isServed=true on 'b'
          // Now free only 'a'
          cubit.freeTable('a');
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          final other = cubit.state.tables.firstWhere((t) => t.id == 'b');
          expect(other.isOccupied, isTrue,
              reason: 'freeTable(a) must not change table b occupation');
          expect(other.isServed, isTrue,
              reason: 'freeTable(a) must not change table b served status');
        },
      );

      blocTest<TableCubit, TableState>(
        'freeTable(null) is a no-op — emits no states',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([_tableA.copyWith(isOccupied: true)]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          // Capture states after initial load, then call freeTable(null)
          final statesBefore = cubit.state;
          cubit.freeTable(null);
          // Verify state is unchanged
          expect(cubit.state.tables, statesBefore.tables);
          expect(cubit.state.selectedTableId, statesBefore.selectedTableId);
        },
      );
    });

    // ── clearSelection ───────────────────────────────────────────────────────

    group('clearSelection', () {
      blocTest<TableCubit, TableState>(
        'clearSelection only clears selectedTableId',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.tableLayoutEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
          repo = _repoReturning([_tableA.copyWith(isOccupied: true)]);
        },
        build: () => TableCubit(prefs: prefs, repo: repo),
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          cubit.selectTable('a');
          cubit.clearSelection();
        },
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.selectedTableId, isNull);
          // Table remains occupied — clearSelection does not change table state
          final tableA = cubit.state.tables.firstWhere((t) => t.id == 'a');
          expect(tableA.isOccupied, isTrue,
              reason: 'clearSelection must not free the table');
        },
      );

      blocTest<TableCubit, TableState>(
        'clearSelection when already null emits a state with selectedTableId=null',
        build: buildCubit,
        act: (cubit) => cubit.clearSelection(),
        verify: (cubit) {
          expect(cubit.state.selectedTableId, isNull);
        },
      );
    });

    // ── TableState.selectedTable getter ──────────────────────────────────────

    group('TableState.selectedTable', () {
      test('returns null when selectedTableId is null', () {
        const state = TableState(tables: [_tableA, _tableB]);
        expect(state.selectedTable, isNull);
      });

      test('returns matching table when selectedTableId is set', () {
        const state = TableState(
          tables: [_tableA, _tableB],
          selectedTableId: 'b',
        );
        expect(state.selectedTable, _tableB);
      });

      test('returns null when selectedTableId does not match any table', () {
        const state = TableState(
          tables: [_tableA],
          selectedTableId: 'z',
        );
        expect(state.selectedTable, isNull);
      });
    });

    // ── TableState.copyWith — sentinel behavior ───────────────────────────────

    group('TableState.copyWith', () {
      test('omitting selectedTableId preserves existing value', () {
        const state = TableState(
          tables: [_tableA],
          selectedTableId: 'a',
        );
        final copy = state.copyWith(enabled: true);
        expect(copy.selectedTableId, 'a');
      });

      test('passing selectedTableId: null explicitly clears it', () {
        const state = TableState(
          tables: [_tableA],
          selectedTableId: 'a',
        );
        final copy = state.copyWith(selectedTableId: null);
        expect(copy.selectedTableId, isNull);
      });
    });

    // ── close ────────────────────────────────────────────────────────────────

    group('close', () {
      test('cubit closes without error when never used', () async {
        final cubit = buildCubit();
        await expectLater(cubit.close(), completes);
      });

      test('cubit closes without error after setEnabled(true)', () async {
        repo = _repoReturning([_tableA]);
        final cubit = TableCubit(prefs: prefs, repo: repo);
        await cubit.setEnabled(true);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await expectLater(cubit.close(), completes);
      });
    });
  });
}
