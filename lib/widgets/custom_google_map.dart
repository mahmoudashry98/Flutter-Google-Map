import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_map/core/utils/map_services.dart';
import 'package:flutter_google_map/core/widgets/custom_list_view.dart';
import 'package:flutter_google_map/core/widgets/custom_text_field.dart';
import 'package:flutter_google_map/models/place_auto_complete_model/place_auto_complete_model.dart';
import 'package:flutter_google_map/core/utils/location_service.dart';
import 'package:flutter_google_map/models/place_model.dart';
import 'package:flutter_google_map/models/routes_model/routes_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  late GoogleMapController mapController;
  late MapServices mapServices;
  late TextEditingController textEditingController;
  late LatLng currentLocation;
  late LatLng destination;

  Timer? debounce;

  //ToDo the session Token make disconnecting between every session when make the request like this(make search and choose the location service this all session if you need to make search again it will generate the new session token)
  String? sessionToken;
  late Uuid uuid;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Set<Polygon> polygons = {};
  Set<Circle> circles = {};
  late Location location;
  List<PlaceAutoCompleteModel> placesAutoComplete = [];
  bool isFirstCall = true;
  @override
  void initState() {
    mapServices = MapServices();
    textEditingController = TextEditingController();
    uuid = const Uuid();
    fetchPredictions();
    initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
    );
    initMarkers();
    // initPolygon();
    // initPolyLines();
    // intiCircles();
    // updateMyLocation();

    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
    textEditingController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      if (debounce?.isActive ?? false) {
        debounce?.cancel();
      }
      debounce = Timer(const Duration(milliseconds: 100), () async {
        sessionToken ??= uuid.v4();
        await mapServices.getPredictions(
          input: textEditingController.text,
          sessionToken: sessionToken!,
          placesAutoComplete: placesAutoComplete,
        );
      });

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          circles: circles,
          polylines: polylines,
          // polygons: polygons,
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            updateCurrentLocation();
          },
          initialCameraPosition: initialCameraPosition,
        ),
        Positioned(
          top: 40,
          left: 20,
          right: 20,
          child: Column(
            children: [
              CustomTextField(
                textEditingController: textEditingController,
              ),
              CustomListView(
                places: placesAutoComplete,
                mapServices: mapServices,
                onSelectPlace: (placeDetailsModel) async {
                  textEditingController.clear();
                  places.clear();
                  sessionToken = null;
                  setState(() {});
                  destination = LatLng(
                    placeDetailsModel.geometry!.location!.lat!,
                    placeDetailsModel.geometry!.location!.lng!,
                  );

                  var points = await mapServices.getRouteData(
                    currentLocation: currentLocation,
                    destination: destination,
                  );
                  setState(() {});
                  mapServices.displayRoute(
                    points,
                    polylines: polylines,
                    mapController: mapController,
                  );

                  setState(() {});
                  // log('${placeDetailsModel.adrAddress}');
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  void initMarkers() {
    var myMarkers = places
        .map(
          (placeModel) => Marker(
            position: placeModel.latLang,
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: placeModel.name,
              snippet: placeModel.address,
              onTap: () {},
            ),
            markerId: MarkerId(
              placeModel.id.toString(),
            ),
          ),
        )
        .toSet();

    markers.addAll(myMarkers);
  }

  void initPolyLines() {
    Polyline polyline = const Polyline(
      //zIndex if you have two  lines on the same map the line take the zIndex == 1 and the second line == 2 this is meaning the line 1 draw on the line 2
      zIndex: 1,
      width: 5,
      color: Colors.red,
      startCap: Cap.roundCap,
      polylineId: PolylineId("poly1"),
      points: [
        LatLng(25.213654264448373, 55.27619180438972),
        LatLng(30.03233440258355, 30.98290617374865),
      ],
    );
    polylines.add(polyline);
  }

  void initPolygon() {
    Polygon polygon = const Polygon(
        geodesic: true,
        holes: [
          [
            LatLng(25.234487574145298, 55.27966432767549),
            LatLng(25.23228555212784, 55.28209863407654),
            LatLng(25.23456621705112, 55.289923190365634),
          ]
        ],
        polygonId: PolygonId("poly1"),
        points: [
          LatLng(25.230712654840204, 55.26540624732648),
          LatLng(25.232757417346246, 55.29748692811175),
          LatLng(25.251394628356003, 55.284880698534884),
        ],
        fillColor: Colors.transparent,
        strokeColor: Colors.red,
        strokeWidth: 1);

    polygons.add(polygon);
  }

  void intiCircles() {
    Circle circle = Circle(
      circleId: const CircleId("circle1"),
      center: const LatLng(25.20930688745014, 55.26080765355656),
      fillColor: Colors.black.withOpacity(0.1),
      radius: 1000,
      strokeColor: Colors.red,
      strokeWidth: 1,
    );
    circles.add(circle);
  }

  void updateCurrentLocation() async {
    try {
      currentLocation = await mapServices.updateCurrentLocation(
          mapController: mapController, markers: markers);
      setState(() {});
    } on LocationServiceException catch (e) {
      // log(e.toString());
    } on LocationPermissionException catch (e) {
      //ToDo:
    } catch (e) {
      // log(e.toString());
    }
  }

  void updateMyCamera(LocationData locationData) {
    currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    if (isFirstCall) {
      CameraPosition cameraPosition = CameraPosition(
        target: currentLocation,
        zoom: 17,
      );
      mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      isFirstCall = false;
    } else {
      mapController.animateCamera(CameraUpdate.newLatLng(currentLocation));
    }
  }

  List<LatLng> getDecodedRoute(
      PolylinePoints polylinePoints, RoutesModel routesData) {
    List<PointLatLng> result = polylinePoints
        .decodePolyline(routesData.routes!.first.polyline!.encodedPolyline!);

    List<LatLng> points = result
        .map(
          (point) => LatLng(point.latitude, point.longitude),
        )
        .toList();
    return points;
  }
}
