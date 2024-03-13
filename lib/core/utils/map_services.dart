import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_map/core/utils/google_maps_place_service.dart';
import 'package:flutter_google_map/core/utils/location_service.dart';
import 'package:flutter_google_map/core/utils/routes_service.dart';
import 'package:flutter_google_map/models/location_info_model/lat_lng.dart';
import 'package:flutter_google_map/models/location_info_model/location.dart';
import 'package:flutter_google_map/models/location_info_model/location_info_model.dart';
import 'package:flutter_google_map/models/place_auto_complete_model/place_auto_complete_model.dart';
import 'package:flutter_google_map/models/place_details_model/place_details_model.dart';
import 'package:flutter_google_map/models/routes_model/routes_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapServices {
  PlaceService placeService = PlaceService();
  LocationService locationService = LocationService();
  RoutesServices routesService = RoutesServices();

  Future<void> getPredictions({
    required String input,
    required String sessionToken,
    required List<PlaceAutoCompleteModel> placesAutoComplete,
  }) async {
    if (input.isNotEmpty) {
      var result = await placeService.getPredictions(
        input: input,
        sessionToken: sessionToken,
      );
      placesAutoComplete.clear();
      placesAutoComplete.addAll(result);
    } else {
      placesAutoComplete.clear();
    }
  }

  Future<List<LatLng>> getRouteData({
    required LatLng currentLocation,
    required LatLng destination,
  }) async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        ),
      ),
    );

    LocationInfoModel destinationData = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: destination.latitude,
          longitude: destination.longitude,
        ),
      ),
    );
    RoutesModel routesData = await routesService.fetchRoutes(
      origin: origin,
      destination: destinationData,
    );
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> points = getDecodedRoute(polylinePoints, routesData);
    return points;
  }

  List<LatLng> getDecodedRoute(
      PolylinePoints polylinePoints, RoutesModel routesData) {
    List<PointLatLng> result = polylinePoints
        .decodePolyline(routesData.routes!.first.polyline!.encodedPolyline!);
    List<LatLng> points =
        result.map((point) => LatLng(point.latitude, point.longitude)).toList();
    return points;
  }

  void displayRoute(
    List<LatLng> points, {
    required Set<Polyline> polylines,
    required GoogleMapController mapController,
  }) {
    Polyline route = Polyline(
      polylineId: const PolylineId("route"),
      color: Colors.blue,
      width: 5,
      points: points,
      geodesic: true,
      consumeTapEvents: true,
      onTap: () {},
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
    polylines.add(route);

    LatLngBounds bounds = getLatLngBounds(points);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(
      bounds,
      100,
    ));
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    var southWestLatitude = points.first.latitude;
    var southWestLongitude = points.first.longitude;
    var northEastLatitude = points.first.latitude;
    var northEastLongitude = points.first.longitude;

    for (var point in points) {
      southWestLatitude = min(southWestLatitude, point.latitude);
      southWestLongitude = min(southWestLongitude, point.longitude);
      northEastLatitude = max(northEastLatitude, point.latitude);
      northEastLongitude = max(northEastLongitude, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(southWestLatitude, southWestLongitude),
      northeast: LatLng(northEastLatitude, northEastLongitude),
    );
  }

  Future<LatLng> updateCurrentLocation({
    required GoogleMapController mapController,
    required Set<Marker> markers,
  }) async {
    var locationData = await locationService.getLocationData();
    var currentLocation =
        LatLng(locationData.latitude!, locationData.longitude!);
    Marker currentLocationMarker = Marker(
        markerId: const MarkerId('My_Location_marker'),
        position: currentLocation);

    CameraPosition myCurrentCameraLocation = CameraPosition(
      target: currentLocation,
      zoom: 17,
    );
    mapController
        .animateCamera(CameraUpdate.newCameraPosition(myCurrentCameraLocation));
    markers.add(currentLocationMarker);

    return currentLocation;
  }

  Future<PlaceDetailsModel> getPlaceDetails({
    required String placeId,
  }) async {
    return await placeService.getPlaceDetails(
      placeId: placeId,
    );
  }
}
