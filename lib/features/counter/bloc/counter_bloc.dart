import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Event
sealed class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

final class CounterIncrementPressed extends CounterEvent {}

final class CounterDecrementPressed extends CounterEvent {}

// State
final class CounterState extends Equatable {
  const CounterState({this.initialValue = 0, this.currentValue = 0});

  final int initialValue;
  final int currentValue;

  CounterState copyWith({int? initialValue, int? currentValue}) {
    return CounterState(
      initialValue: initialValue ?? this.initialValue,
      currentValue: currentValue ?? this.currentValue,
    );
  }

  @override
  List<Object> get props => [initialValue, currentValue];
}

// Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState()) {
    on<CounterIncrementPressed>((event, emit) {
      emit(state.copyWith(currentValue: state.currentValue + 1));
    });

    on<CounterDecrementPressed>((event, emit) {
      emit(state.copyWith(currentValue: state.currentValue - 1));
    });
  }
}
