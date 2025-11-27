import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:waslny/core/api/status_code.dart';
import 'package:waslny/core/error/exceptions.dart';
import 'package:waslny/core/preferences/preferences.dart';
import 'package:waslny/core/api/app_interceptors.dart';
import 'package:waslny/core/api/base_api_consumer.dart';
import 'package:waslny/core/api/end_points.dart';
import 'package:waslny/injector.dart' as injector;

class DioConsumer implements BaseApiConsumer {
  final Dio client;

  DioConsumer({required this.client}) {
    _configureClient();
    _addInterceptors();
  }

  void _configureClient() {
    (client.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };

    client.options
      ..baseUrl = EndPoints.baseUrl
      ..responseType = ResponseType.plain
      ..followRedirects = false
      ..receiveTimeout = const Duration(minutes: 1)
      ..connectTimeout = const Duration(minutes: 1)
      ..sendTimeout = const Duration(minutes: 1)
      ..validateStatus = (status) {
        return status != null && status < StatusCode.internalServerError;
      };
  }

  void _addInterceptors() {
    client.interceptors.add(injector.serviceLocator<AppInterceptors>());
    if (kDebugMode) {
      client.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _makeRequest(
      () async => client.get(
        path,
        queryParameters: queryParameters,
        options: options ?? await _getOptions(),
      ),
    );
  }

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _makeRequest(
      () async => client.post(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body!) : body,
        queryParameters: queryParameters,
        options: options ?? await _getOptions(),
      ),
    );
  }

  @override
  Future<dynamic> put(
    String path, {
    bool formDataIsEnabled = false,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _makeRequest(
      () async => client.put(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body!) : body,
        queryParameters: queryParameters,
        options: options ?? await _getOptions(),
      ),
    );
  }

  @override
  Future<dynamic> delete(
    String path, {
    bool formDataIsEnabled = false,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _makeRequest(
      () async => client.delete(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body!) : body,
        queryParameters: queryParameters,
        options: options ?? await _getOptions(),
      ),
    );
  }

  Future<Options> _getOptions() async {
    final token = await _getToken();
    final lang = await Preferences.instance.getSavedLang();
    log('myToken=>$token');
    return Options(
      headers: {
        if (token != null) 'Authorization': token,
        'Connection': 'keep-alive',
        'Accept': 'application/json',
        // 'Accept': '*/*',
        'Accept-Language': lang,
      },
    );
  }

  Future<String?> _getToken() async {
    final userModel = await Preferences.instance.getUserModel();

    if (userModel.data != null) {
      return userModel.data?.token;
    } else {
      return null;
    }
  }

  Future<dynamic> _makeRequest(Future<Response> Function() request) async {
    try {
      final response = await request();
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioException(error);
    }
  }

  dynamic _handleResponseAsJson(Response<dynamic> response) {
    if (response.data != null) {
      return jsonDecode(response.data);
    } else {
      throw const FetchDataException();
    }
  }

  void _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const FetchDataException();
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case StatusCode.badRequest:
            throw const BadRequestException();
          case StatusCode.unautherized:
            throw const UnauthorizedException();
          case StatusCode.forbidden:
          case StatusCode.notFound:
            throw const NotFoundException();
          case StatusCode.conflict:
            throw const ConflictException();
          case StatusCode.internalServerError:
            throw const InternalServerErrorException();
          default:
            throw const FetchDataException();
        }
      case DioExceptionType.cancel:
        throw const FetchDataException();
      case DioExceptionType.unknown:
      default:
        throw const NoInternetConnectionException();
    }
  }
}
