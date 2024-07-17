import 'dart:collection';
import 'dart:developer';

import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

import '../api/base_config.dart';

class AudioRepo extends BaseRepository {
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      Response response = await dio.post(
        "$baseUrl/minerlogin",
        data: {
          "username": username,
          "password": password,
        },
      );

      print("response: $response.toString()");

      var jsonResponse =
          jsonDecode(response.toString()) as Map<String, dynamic>;

      if (jsonResponse.containsKey('success')) {
        await store('userId', jsonResponse['user_id']);
        await store('minerId', jsonResponse['miner_id']);
      }

      return jsonResponse;
    } catch (e) {
      log("error ${e.toString()}");
    }

    return null;
  }

  Future<Uint8List?> getAudio() async {
    final minerId = await storage.read(key: "minerId");
    try {
      Response response = await dio.get(
        "$baseUrl/get_audio",
        queryParameters: {"miner_id": minerId},
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      Uint8List byteData = Uint8List.fromList(response.data);
      // List<double> amp = extractAmplitudeValues(byteData);

      // print("%%%%%%%%%%%%%%%%");
      // print(amp);
      // print("%%%%%%%%%%%%%%%%");

      return byteData;
    } catch (e) {
      log("error ${e.toString()}");
    }

    return null;
  }

  Future<Map<String, dynamic>?> getScript(int idx) async {
    final userId = await storage.read(key: "userId");
    try {
      Response response = await dio.get(
        "$baseUrl/get_script",
        queryParameters: {"user_id": userId, "idx": idx},
      );

      var jsonResponse = jsonDecode(response.toString());
      return jsonResponse;
    } catch (e) {
      log("error ${e.toString()}");
    }

    return null;
  }

  Future store(String key, dynamic value) async {
    await storage.write(
      key: key,
      value: value,
    );
  }
}
