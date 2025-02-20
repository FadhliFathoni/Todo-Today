import 'package:hive_flutter/hive_flutter.dart';

part 'TodoModel.g.dart';

@HiveType(typeId: 1)
class TodoModel {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? username;
  @HiveField(2)
  String? title;
  @HiveField(3)
  String? description;
  @HiveField(4)
  String? date;
  @HiveField(5)
  int? everyday;
  @HiveField(6)
  int? done;

  TodoModel(
      {this.id,
      this.username,
      this.title,
      this.description,
      this.date,
      this.everyday,
      this.done});

  TodoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    title = json['title'];
    description = json['description'];
    date = json['date'];
    everyday = json['everyday'];
    done = json['done'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['title'] = this.title;
    data['description'] = this.description;
    data['date'] = this.date;
    data['everyday'] = this.everyday;
    data['done'] = this.done;
    return data;
  }
}
