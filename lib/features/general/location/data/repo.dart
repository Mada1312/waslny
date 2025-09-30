import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/preferences/preferences.dart';

import 'models/get_address_map_model.dart';

class LocationRepo {
  BaseApiConsumer api;
  LocationRepo(this.api);

  Future<Either<Failure, GetAddressMapModel>> getAddressMap({
    required double lat,
    required double long,
  }) async {
    final lang = await Preferences.instance.getSavedLang();
    try {
      var response = await api.get(
        EndPoints.getAddressMapUrl,
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': long,
        },
        options: Options(
          headers: {
            'User-Agent': 'com.octobus.waslny',
            'Accept-Language': lang,
          },
        ),
      );
      return Right(GetAddressMapModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, List<GetAddressMapModel>>> searchOnMap({
    required String searchKey,
  }) async {
    final lang = await Preferences.instance.getSavedLang();
    try {
      var response = await api.get(
        EndPoints.searchOnMapUrl,
        queryParameters: {
          'format': 'json',
          'q': searchKey,
        },
        options: Options(
          headers: {
            'User-Agent': 'com.octobus.waslny',
            'Accept-Language': lang,
          },
        ),
      );
      return Right((List.from(response)
          .map((e) => GetAddressMapModel.fromJson(e))
          .toList()));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
