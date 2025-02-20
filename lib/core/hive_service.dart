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
      await Hive.openBox<List<TodoModel>>(_keyTodoToday);
    }
    if (!Hive.isBoxOpen(_keyHistoryToday)) {
      await Hive.openBox<List<TodoModel>>(_keyHistoryToday);
    }
  }

  List<TodoModel>? getTodoToday() {
    return Hive.box<List<TodoModel>>(_keyTodoToday).get(0);
  }

  void initTodoToday(List<TodoModel> todos) {
    Hive.box<List<TodoModel>>(_keyTodoToday).put(0, todos);
  }

  List<TodoModel>? getHistoryToday() {
    return Hive.box<List<TodoModel>>(_keyHistoryToday).get(0);
  }

  void initHistoryToday(List<TodoModel> todos) {
    Hive.box<List<TodoModel>>(_keyHistoryToday).put(0, todos);
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
