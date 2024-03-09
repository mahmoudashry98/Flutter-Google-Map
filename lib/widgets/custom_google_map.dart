import 'package:flutter/material.dart';
import 'package:flutter_google_map/models/place_model.dart';
import 'package:flutter_google_map/utils/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  GoogleMapController? mapController;
  late LocationService locationService;

  Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  Set<Polygon> polygons = {};

  Set<Circle> circles = {};

  late Location location;

  bool isFirstCall = true;

  @override
  void initState() {
    locationService = LocationService();
    initialCameraPosition = const CameraPosition(
      zoom: 20,
      target: LatLng(25.213654264448373, 55.27619180438972),
    );
    initMarkers();
    initPolygon();
    initPolyLines();
    intiCircles();
    updateMyLocation();
    super.initState();
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          circles: circles,
          // polylines: polylines,
          polygons: polygons,
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          initialCameraPosition: initialCameraPosition,
        ),
        // Positioned(
        //   bottom: 20,
        //   left: 80,
        //   right: 80,
        //   child: ElevatedButton(
        //     onPressed: () {
        //       mapController!.animateCamera(
        //         CameraUpdate.newCameraPosition(
        //           const CameraPosition(
        //             target: LatLng(30.03233440258355, 30.98290617374865),
        //             zoom: 10.0,
        //           ),
        //         ),
        //       );
        //     },
        //     child: const Text("Change Location"),
        //   ),
        // ),
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
    await locationService.checkAndRequestLocationService();
    var hasPermission =
        await locationService.checkAndRequestLocationPermission();
    if (hasPermission) {
      locationService.getRealTimeLocationData((locationData) {
        setMyLocationMarker(locationData);
        updateMyCamera(locationData);
      });
    }
  }

  void updateMyCamera(LocationData locationData) {
    if (isFirstCall) {
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 17,
      );
      mapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      isFirstCall = false;
    } else {
      mapController?.animateCamera(CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!)));
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
