import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_google_map/models/place_auto_complete_model/place_auto_complete_model.dart';
import 'package:flutter_google_map/models/place_details_model/place_details_model.dart';

class PlaceService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey = 'AIzaSyDKC-R8dpezg5j7WXe578Iy4L5CPBVR9G4';
  final Dio dio = Dio();
  Future<List<PlaceAutoCompleteModel>> getPredictions(
      {required String input, required String sessionToken}) async {
    var response = await dio.get(
      '$baseUrl/autocomplete/json?input=$input&sessiontoken =$sessionToken&key=$apiKey',
    );
    if (response.statusCode == 200) {
      log(response.data.toString());
      return (response.data['predictions'] as List)
          .map((e) => PlaceAutoCompleteModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<PlaceDetailsModel> getPlaceDetails({
    required String placeId,
  }) async {
    var response = await dio.get(
      '$baseUrl/details/json?place_id=$placeId&key=$apiKey',
      // queryParameters: {'input': input, 'types': 'geocode'},
    );
    if (response.statusCode == 200) {
      log(response.data.toString());
      var data = response.data['result'];

      return PlaceDetailsModel.fromJson(data);
    } else {
      throw Exception('Failed to load predictions');
    }
  }
}
