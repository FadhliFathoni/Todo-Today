import 'package:todo_today/model/TodoModel.dart';

abstract class HistoryStates {}

class HistoryInitial extends HistoryStates {}

class HistoryLoading extends HistoryStates {}

class HistoryLoaded extends HistoryStates {
  final List<TodoModel> todos;
  HistoryLoaded(this.todos);
}

class HistoryError extends HistoryStates {
  final String error;
  HistoryError(this.error);
}
