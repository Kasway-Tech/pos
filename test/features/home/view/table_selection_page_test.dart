import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/table/table_cubit.dart';
import 'package:kasway/app/table/table_state.dart';
import 'package:kasway/data/models/table_item.dart';
import 'package:kasway/features/home/view/table_selection_page.dart';
import 'package:mocktail/mocktail.dart';

class MockTableCubit extends MockCubit<TableState> implements TableCubit {}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _freeTable = TableItem(
  id: 'free-1',
  label: '1',
  seats: 4,
  x: 100,
  y: 100,
  isOccupied: false,
  isServed: false,
);

const _occupiedTable = TableItem(
  id: 'occ-1',
  label: '2',
  seats: 2,
  x: 200,
  y: 200,
  isOccupied: true,
  isServed: false,
);

const _servedTable = TableItem(
  id: 'srv-1',
  label: '3',
  seats: 4,
  x: 300,
  y: 100,
  isOccupied: true,
  isServed: true,
);

// ---------------------------------------------------------------------------
// Router builder
//
// TableSelectionPage uses context.pop() (go_router extension). The router
// must have a backstack entry to pop to — we do this by starting at '/' and
// then calling router.push('/table-selection') inside each test.
// ---------------------------------------------------------------------------

GoRouter _buildRouter(MockTableCubit tableCubit) => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/table-selection',
          builder: (context, state) => BlocProvider<TableCubit>.value(
            value: tableCubit,
            child: const TableSelectionPage(),
          ),
        ),
      ],
    );

void main() {
  late MockTableCubit tableCubit;

  setUp(() {
    tableCubit = MockTableCubit();
    // Default: feature enabled with a free and an occupied table
    when(() => tableCubit.state).thenReturn(
      const TableState(
        enabled: true,
        tables: [_freeTable, _occupiedTable],
      ),
    );
    when(() => tableCubit.selectTable(any())).thenReturn(null);
    when(() => tableCubit.markServed(any())).thenReturn(null);
    when(() => tableCubit.freeTable(any())).thenReturn(null);
  });

  // ── Empty state ────────────────────────────────────────────────────────────

  group('empty state', () {
    testWidgets('shows empty state widget when no tables configured',
        (tester) async {
      when(() => tableCubit.state).thenReturn(
        const TableState(enabled: true, tables: []),
      );
      final router = _buildRouter(tableCubit);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/table-selection');
      await tester.pumpAndSettle();

      expect(find.text('No tables configured'), findsOneWidget);
      expect(find.text('Go to Table Layout'), findsOneWidget);
    });

    testWidgets('does not show chip list when tables are empty', (tester) async {
      when(() => tableCubit.state).thenReturn(
        const TableState(enabled: true, tables: []),
      );
      final router = _buildRouter(tableCubit);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/table-selection');
      await tester.pumpAndSettle();

      expect(find.text('Table 1'), findsNothing);
    });
  });

  // ── Chip list rendering ────────────────────────────────────────────────────

  group('chip list', () {
    testWidgets('renders a chip for each table', (tester) async {
      final router = _buildRouter(tableCubit);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/table-selection');
      await tester.pumpAndSettle();

      expect(find.text('Table 1'), findsOneWidget);
      expect(find.text('Table 2'), findsOneWidget);
    });

    testWidgets('renders chips for all three status variants', (tester) async {
      when(() => tableCubit.state).thenReturn(
        const TableState(
          enabled: true,
          tables: [_freeTable, _occupiedTable, _servedTable],
        ),
      );
      final router = _buildRouter(tableCubit);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/table-selection');
      await tester.pumpAndSettle();

      expect(find.text('Table 1'), findsOneWidget); // free
      expect(find.text('Table 2'), findsOneWidget); // occupied
      expect(find.text('Table 3'), findsOneWidget); // served
    });
  });

  // ── _selectTable — free table ──────────────────────────────────────────────

  group('_selectTable — free table', () {
    testWidgets('tapping a free chip calls selectTable(id)', (tester) async {
      final router = _buildRouter(tableCubit);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/table-selection');
      await tester.pumpAndSettle();

      // Tap the enabled chip for the free table
      await tester.tap(find.text('Table 1'));
      await tester.pump();

      verify(() => tableCubit.selectTable('free-1')).called(1);
    });

    testWidgets('selecting a free table pops the page', (tester) async {
      final router = _buildRouter(tableCubit);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/table-selection');
      await tester.pumpAndSettle();

      expect(find.byType(TableSelectionPage), findsOneWidget);

      await tester.tap(find.text('Table 1'));
      await tester.pumpAndSettle();

      // After pop, TableSelectionPage should no longer be visible
      expect(find.byType(TableSelectionPage), findsNothing);
    });
  });

  // ── _selectTable — occupied table ──────────────────────────────────────────

  group('_selectTable — occupied table', () {
    testWidgets('tapping an occupied chip does not call selectTable',
        (tester) async {
      final router = _buildRouter(tableCubit);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/table-selection');
      await tester.pumpAndSettle();

      // FilterChip for an occupied table has onSelected=null, so tapping it
      // is a no-op. Attempt tap on the chip text and verify no call was made.
      await tester.tap(find.text('Table 2'), warnIfMissed: false);
      await tester.pump();

      verifyNever(() => tableCubit.selectTable(any()));
    });
  });

  // ── AppBar ─────────────────────────────────────────────────────────────────

  group('AppBar', () {
    testWidgets('shows "Select Table" title', (tester) async {
      final router = _buildRouter(tableCubit);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/table-selection');
      await tester.pumpAndSettle();

      expect(find.text('Select Table'), findsOneWidget);
    });
  });
}
