import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_action_state.dart';

class GlobalActionCubit extends Cubit<GlobalActionState> {
  GlobalActionCubit() : super(GlobalActionInitial());
}
