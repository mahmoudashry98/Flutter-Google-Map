import 'package:flutter/material.dart';
import 'package:flutter_google_map/models/place_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  late GoogleMapController mapController;

  Set<Marker> markers = {
    const Marker(
      markerId: MarkerId("marker1"),
      position: LatLng(25.213654264448373, 55.27619180438972),
    ),
  };

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      zoom: 10.0,
      target: LatLng(25.213654264448373, 55.27619180438972),
    );
    initMarkers();
    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          initialCameraPosition: initialCameraPosition,
        ),
        Positioned(
          bottom: 20,
          left: 80,
          right: 80,
          child: ElevatedButton(
            onPressed: () {
              mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(
                    target: LatLng(30.03233440258355, 30.98290617374865),
                    zoom: 10.0,
                  ),
                ),
              );
            },
            child: const Text("Change Location"),
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
}
