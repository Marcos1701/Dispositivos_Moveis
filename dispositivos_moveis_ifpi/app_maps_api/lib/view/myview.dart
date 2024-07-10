import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  //texto contendo a localização atual
  String _localizacao = 'Casa';

  BitmapDescriptor? _marker;

  Future<void> _changeLocation() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        _localizacao == "Casa" ? _ifpiCameraPosition : _casa));
    setState(() {
      _localizacao = _localizacao == "Casa" ? "IFPI" : "Casa";
    });
  }

  static const CameraPosition _casa = CameraPosition(
    target: LatLng(-5.093708656214135, -42.75412754927936),
    zoom: 18,
  );

  static const CameraPosition _ifpiCameraPosition = CameraPosition(
    target: LatLng(-5.088337, -42.81065),
    zoom: 18,
  );

  Future<void> _getPermission() async {
    await Geolocator.requestPermission();
  }

  Future<BitmapDescriptor> getMarker() async {
    return await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5, size: Size(50, 50)),
        'assets/Logo-IFPI-Vertical.png');
  }

  @override
  @override
  void initState() {
    super.initState();
    initializeMap();
  }

  void loadMakerIcon() async {
    setState(() {
      _marker = null;
    });
    _marker = await getMarker();
    setState(() {});
  }

  void initializeMap() async {
    await _getPermission();
    loadMakerIcon();
  }

  Set<Marker> _getMarkers() {
    return {
      Marker(
          markerId: const MarkerId('1'),
          position: const LatLng(-5.093708656214135, -42.75412754927936),
          infoWindow: const InfoWindow(title: 'Casa'),
          icon: _marker != null // se o marcador ainda não foi carregado
              ? _marker! // então carregue o marcador
              : BitmapDescriptor.defaultMarker // se o marcador ja foi carregado
          ),
      const Marker(
        markerId: MarkerId('2'),
        position: LatLng(-5.088408, -42.81065),
        infoWindow: InfoWindow(title: 'IFPI'),
      ),
    };
  }

  // Future<BitmapDescriptor> getMarker() async {
  //   return await BitmapDescriptor.fromAssetImage(
  //       const ImageConfiguration(devicePixelRatio: 2.5, size: Size(50, 50)),
  //       'assets/Logo-IFPI-Vertical.png');
  // }

  Future<BitmapDescriptor> fromAssetSync(String assetName) async {
    final ByteData data = await rootBundle.load(assetName);
    final Uint8List bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return BitmapDescriptor.fromBytes(bytes);
  }

  Future<BitmapDescriptor> getMarkerSync() {
    return fromAssetSync('assets/Logo-IFPI-Vertical.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _controller.complete,
        initialCameraPosition: _casa,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.hybrid,
        markers: _getMarkers(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _changeLocation,
        label: const Text('Simboraaaaa!!!'),
        icon: const Icon(Icons.change_circle),
      ),
    );
  }
}
