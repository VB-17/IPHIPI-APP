import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:typed_data';

//const String baseUrl = "http://localhost:1337";
// const String baseUrl = "http://13.232.191.5:1337";
const String baseUrl = "https://web.iphipi.com";

abstract class BaseRepository {
  final dio = Dio();
  final storage = const FlutterSecureStorage();
}


