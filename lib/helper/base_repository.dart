import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:base_mobile_indieapps/models/base_response.dart';
import 'package:base_mobile_indieapps/models/meta.dart';
import 'package:base_mobile_indieapps/utils/constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    hide Options;
import 'package:get_it/get_it.dart';
import 'package:retry/retry.dart';

import 'exception_helper.dart';

class BaseRepository {
  final Dio dio = GetIt.I<Dio>();
  final FlutterSecureStorage secureStorage = GetIt.I<FlutterSecureStorage>();

  Future<BaseResponse> fetch(String api,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final token = await secureStorage.read(key: kToken);

      final Map<String, dynamic>  headers = {};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await retry(
        () => dio.get(
          api,
          queryParameters: queryParameters,
          options: Options(responseType: ResponseType.json, headers: headers),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      return BaseResponse(
        statusCode: response.statusCode,
        data: response.data['data'] ?? response.data,
        meta: response.data['meta'] != null
            ? Meta.fromJson(response.data['meta'])
            : null,
      );
    } on DioError catch (e) {
      return ExceptionHelper(e).catchException();
    }
  }

  Future<BaseResponse> post(
    String api, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await secureStorage.read(key: kToken);

     final Map<String, dynamic>  headers = {};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await retry(
        () => dio.post(
          api,
          data: json.encode(data),
          options: Options(responseType: ResponseType.json, headers: headers),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      return BaseResponse(
        statusCode: response.statusCode,
        data: response.data['data'],
        message: response.data['message'],
      );
    } on DioError catch (e) {
      return ExceptionHelper(e).catchException();
    }
  }

  Future<BaseResponse> put(String api,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters}) async {
    try {
      final token = await secureStorage.read(key: kToken);

      final Map<String, dynamic>  headers = {};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      
      final response = await retry(
        () => dio.put(
          api,
          data: json.encode(data),
          queryParameters: queryParameters,
          options: Options(headers: headers),
        ),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      return BaseResponse(
        statusCode: response.statusCode,
        data: response.data['data'],
        message: response.data['message'],
      );
    } on DioError catch (e) {
      return ExceptionHelper(e).catchException();
    }
  }
}
