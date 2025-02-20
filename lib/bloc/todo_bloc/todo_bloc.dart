import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_today/API/todoAPI.dart';
import 'package:todo_today/bloc/todo_bloc/todo_state.dart';
import 'package:todo_today/core/hive_service.dart';
import 'package:todo_today/model/TodoModel.dart';

class TodoTodayBloc extends Cubit<TodoState> {
  TodoTodayBloc() : super(TodoInitial()) {}

  Future<void> initializeTodo() async {
    emit(TodoLoading());
    List<TodoModel> result = await TodoAPI().getTodo(isHistory: false);
    GetIt.I<HiveService>().initTodoToday(result);
    if (!isClosed) emit(TodoLoaded(result));
  }

  Future<void> getTodo() async {
    try {
      var cache = GetIt.I<HiveService>().getTodoToday();
      if (cache != null) {
        if (!isClosed) emit(TodoLoaded(cache));
        return;
      }
      var result = await TodoAPI().getTodo(isHistory: false);
      GetIt.I<HiveService>().initTodoToday(result);

      if (!isClosed) emit(TodoLoaded(result));
    } catch (e) {
      print("Error: " + e.toString());
      emit(TodoError(e.toString()));
    }
  }
}
