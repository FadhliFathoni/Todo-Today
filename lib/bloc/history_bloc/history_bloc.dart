import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_today/API/todoAPI.dart';
import 'package:todo_today/bloc/history_bloc/history_state.dart';
import 'package:todo_today/core/hive_service.dart';
import 'package:todo_today/model/TodoModel.dart';

class HistoryTodoBloc extends Cubit<HistoryStates> {
  HistoryTodoBloc() : super(HistoryInitial()) {}

  Future<void> initializeTodo() async {
    emit(HistoryLoading());
    List<TodoModel> result = await TodoAPI().getTodo(isHistory: true);
    GetIt.I<HiveService>().initHistoryToday(result);
    if (!isClosed) emit(HistoryLoaded(result));
  }

  Future<void> getTodo() async {
    print("MASUK SINI KEU");
    try {
      var cache = GetIt.I<HiveService>().getHistoryToday();
      if (cache != null && cache.isNotEmpty) {
        if (!isClosed) emit(HistoryLoaded(cache));
        return;
      }
      emit(HistoryLoading());
      var result = await TodoAPI().getTodo(isHistory: true);
      GetIt.I<HiveService>().initHistoryToday(result);
      if (!isClosed) emit(HistoryLoaded(result));
    } catch (e) {
      print("Error: " + e.toString());
      emit(HistoryError(e.toString()));
    }
  }
}
