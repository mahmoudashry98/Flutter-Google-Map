import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_google_map/core/utils/google_maps_place_service.dart';
import 'package:flutter_google_map/core/widgets/custom_list_view.dart';
import 'package:flutter_google_map/core/widgets/custom_text_field.dart';
import 'package:flutter_google_map/models/place_auto_complete_model/place_auto_complete_model.dart';
import 'package:flutter_google_map/core/utils/location_service.dart';
import 'package:flutter_google_map/models/place_model.dart';
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
  late LocationService locationService;
  late GoogleMapPlaceService googleMapPlaceService;
  late TextEditingController textEditingController;

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
    locationService = LocationService();
    googleMapPlaceService = GoogleMapPlaceService();
    textEditingController = TextEditingController();
    uuid = const Uuid();
    fetchPredictions();
    initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
    );
    // initMarkers();
    // initPolygon();
    // initPolyLines();
    // intiCircles();
    // updateMyLocation();

    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      sessionToken ??= uuid.v4();
      log('$sessionToken');
      
      if (textEditingController.text.isNotEmpty) {
        var result = await googleMapPlaceService.getPredictions(
          input: textEditingController.text,
          sessionToken: sessionToken!,
        );
        placesAutoComplete.clear();
        placesAutoComplete.addAll(result);
        setState(() {});
      } else {
        placesAutoComplete.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          circles: circles,
          // polylines: polylines,
          polygons: polygons,
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            updateMyLocation();
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
                service: googleMapPlaceService,
                onSelectPlace: (placeDetailsModel) {
                  textEditingController.clear();
                  places.clear();
                  sessionToken = null;
                  setState(() {});
                  log('${placeDetailsModel.adrAddress}');
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

  void updateMyLocation() async {
    try {
      var locationData = await locationService.getLocationData();
      CameraPosition myCurrentCameraLocation = CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 17,
      );
      mapController.animateCamera(
          CameraUpdate.newCameraPosition(myCurrentCameraLocation));
      setMyLocationMarker(locationData);
    } catch (e) {
      log(e.toString());
    }
  }

  void updateMyCamera(LocationData locationData) {
    LatLng currentLocation =
        LatLng(locationData.latitude!, locationData.longitude!);
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

  void setMyLocationMarker(LocationData locationData) {
    var myMarkers = Marker(
        markerId: const MarkerId('My_Location_marker'),
        position: LatLng(locationData.latitude!, locationData.longitude!));
    markers.add(myMarkers);
    setState(() {});
  }
}
