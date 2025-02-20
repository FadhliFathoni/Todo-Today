import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_today/core/hive_service.dart';

class GetItContainer {
  static void initialize() {
    GetIt.I.registerSingleton<HiveService>(HiveService());
  }

  static void initializeConfig(Dio dio) {
    GetIt.I.registerSingleton<Dio>(dio);
  }
}
