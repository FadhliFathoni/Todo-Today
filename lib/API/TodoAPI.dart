import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/bloc/todo_bloc/todo_bloc.dart';
import 'package:todo_today/model/TodoModel.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';

class TodoAPI {
  var dio = Dio();
  var baseUrl = dotenv.get("BASE_URL");

  Options headers() {
    return Options(headers: {"Accept": "application/json"});
  }

  Future<List<TodoModel>> getTodo({required bool isHistory}) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var username = prefs.getString("user");
      var url = baseUrl;
      if (isHistory) {
        url += "/history-todo?username=$username";
      } else {
        url += "/get-todo?username=$username";
      }
      var response = await dio.get(url);
      var list = (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      return list
          .map(
            (e) => TodoModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      print("Error " + e.toString());
      return [];
    }
  }

  void registerTodo(BuildContext context, {required TodoModel todo}) async {
    await dio.post(baseUrl + "/register-todo",
        data: {
          "username": todo.username,
          "title": todo.title,
          "description": todo.description,
          "date": todo.date,
          "everyday": todo.everyday,
          "done": todo.done,
        },
        options: headers());
  }

  void updateTodo(BuildContext context, {required TodoModel todo}) async {
    await dio.post(baseUrl + "/update-todo/${todo.id}",
        data: {
          "username": todo.username,
          "title": todo.title,
          "description": todo.description,
          "date": todo.date,
          "everyday": todo.everyday,
          "done": todo.done,
        },
        options: headers());
  }

  void doneTodo(int id) async {
    try {
      var response =
          await dio.post(baseUrl + "/done-todo/$id", options: headers());
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Sukses approve todo");
      } else {
        print("Gagal done todo");
      }
    } catch (e) {
      print("Error " + e.toString());
    }
  }

  void delete(int id) async {
    try {
      var response =
          await dio.post(baseUrl + "/delete-todo/$id", options: headers());
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Sukses delete todo");
      } else {
        print("Gagal delete todo");
      }
    } catch (e) {
      print("Error " + e.toString());
    }
  }
}
