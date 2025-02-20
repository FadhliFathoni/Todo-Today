import 'package:todo_today/model/TodoModel.dart';

abstract class TodoState {}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;
  TodoLoaded(this.todos);
}

class TodoError extends TodoState {
  final String error;
  TodoError(this.error);
}
