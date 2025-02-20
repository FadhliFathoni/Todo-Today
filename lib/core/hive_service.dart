import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_today/model/TodoModel.dart';

class HiveService {
  final _initialOpen = 'initial-open';
  final _keyTodoToday = 'todo-today';
  final _keyHistoryToday = 'history-today';

  Future init() async {
    await Hive.initFlutter();
  }

  Future openBoxes() async {
    if (!Hive.isBoxOpen(_initialOpen)) {
      await Hive.openBox<bool>(_initialOpen);
    }

    if (!Hive.isBoxOpen(_keyTodoToday)) {
      Hive.registerAdapter(TodoModelAdapter());
      await Hive.openBox<TodoModel>(_keyTodoToday);
    }
    if (!Hive.isBoxOpen(_keyHistoryToday)) {
      await Hive.openBox<TodoModel>(_keyHistoryToday);
    }
  }

  List<TodoModel>? getTodoToday() {
    final box = Hive.box<TodoModel>(_keyTodoToday);
    return box.values.toList();
  }

  void initTodoToday(List<TodoModel> todos) async {
    final box = Hive.box<TodoModel>(_keyTodoToday);
    await box.clear();
    for (var todo in todos) {
      await box.put(todo.id, todo);
    }
  }

  List<TodoModel>? getHistoryToday() {
    final box = Hive.box<TodoModel>(_keyHistoryToday);
    return box.values.toList();
  }

  void initHistoryToday(List<TodoModel> todos) async {
    final box = Hive.box<TodoModel>(_keyHistoryToday);
    await box.clear();
    for (var todo in todos) {
      await box.put(todo.id, todo);
    }
  }

  Future<void> clearTodo() async =>
      await Hive.box<List<TodoModel>>(_keyTodoToday).clear();

  Future<void> clearHistory() async =>
      await Hive.box<List<TodoModel>>(_keyHistoryToday).clear();

  Future<void> clearAll() async {
    await Hive.box<List<TodoModel>>(_keyTodoToday).clear();
    await Hive.box<List<TodoModel>>(_keyHistoryToday).clear();
  }
}
