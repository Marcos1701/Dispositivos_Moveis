import 'dart:async';
// import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Uint8List? marketimages;
  List<String> images = [
    'assets/home.png',
    'assets/Logo-IFPI-Vertical.png',
  ];

  final List<int> _sizes = <int>[100, 250];

  final List<String> _titles = <String>[
    'Casa Daniel',
    'IFPI',
  ];

  // created empty list of markers
  final List<Marker> _markers = <Marker>[
    // Marker(
    //     markerId: const MarkerId('0'),
    //     position: const LatLng(-5.093708656214135, -42.75412754927936),
    //     infoWindow: const InfoWindow(title: 'Casa'),
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow))
  ];

  // declared method to get Images
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  final List<LatLng> _latLen = <LatLng>[
    const LatLng(-5.093708656214135, -42.75412754927936),
    const LatLng(-5.088408, -42.81065),
  ];

  void requestPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    // initialize loadData method
    loadData();
    requestPermission();
  }

  // created method for displaying custom markers according to index
  loadData() async {
    for (int i = 0; i < images.length; i++) {
      final Uint8List markIcons = await getImages(images[i], _sizes[i]);
      // makers added according to index
      _markers.add(Marker(
        // given marker id
        markerId: MarkerId(i.toString()),
        // given marker icon
        icon: BitmapDescriptor.fromBytes(markIcons),
        // given position
        position: _latLen[i],
        infoWindow: InfoWindow(
          // given title for marker
          title: _titles[i],
        ),
      ));
      setState(() {});
    }
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
        markers: Set<Marker>.of(_markers),
        onLongPress: _onMapLongPressed,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _changeLocation,
        label: const Text('Change Location'),
        icon: const Icon(Icons.change_circle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // created method for displaying custom markers according to index
    );
  }

  // para adicionar um evento para que se adicione um marcador ao clicar
  // no mapa

  // created method for displaying custom markers according to index
  void _onMapLongPressed(LatLng latLng) {
    // evento disparado quando o mapa é pressionado e segurado por alguns segundos
    Future.delayed(const Duration(seconds: 1), () {
      // adiciona um novo marcador no click
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(_markers.length.toString()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: latLng,
          infoWindow: const InfoWindow(
            title: "Novo Marcador",
          ),
        ));

        _controller.future.then((GoogleMapController controller) {
          controller
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: latLng,
            zoom: 18,
          )));
        });
      });
    });
  }
}
