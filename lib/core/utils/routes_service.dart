import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_google_map/models/location_info_model/location_info_model.dart';
import 'package:flutter_google_map/models/routes_model/routes_model.dart';
import 'package:flutter_google_map/models/routes_modifier_model.dart';

class RoutesServices {
  final Dio dio = Dio();
  final String baseUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = 'AIzaSyDKC-R8dpezg5j7WXe578Iy4L5CPBVR9G4';



  Future<RoutesModel> fetchRoutes({
    required LocationInfoModel origin,
    required LocationInfoModel destination,
    RoutesModifierModel? routesModifier,
  }) async {
    Uri uri = Uri.parse(baseUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
      'X-Goog-Api-Key': apiKey
    };

    Map<String, dynamic> body = {
      "origin": origin.toJson(),
      "destination": destination.toJson(),
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": routesModifier != null
          ? routesModifier.toJson()
          : RoutesModifierModel().toJson(),
      "languageCode": "en-US",
      "units": "IMPERIAL"
    };

    var response = await dio.post(
      uri.toString(),
      options: Options(
        headers: headers,
      ),
      data: body,
    );
    if (response.statusCode == 200) {
      log(response.data.toString());
      return RoutesModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load routes');
    }

  }
}
