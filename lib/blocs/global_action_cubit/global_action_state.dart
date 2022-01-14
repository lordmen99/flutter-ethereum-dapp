part of 'global_action_cubit.dart';

abstract class GlobalActionState extends Equatable {
  const GlobalActionState();

  @override
  List<Object> get props => [];
}

class GlobalActionInitial extends GlobalActionState {}
