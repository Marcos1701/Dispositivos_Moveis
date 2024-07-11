import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> with TickerProviderStateMixin {
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

  // lista de imagens
  Uint8List? marketimages;
  List<String> images = [
    'assets/home.png',
    'assets/Logo-IFPI-Vertical.png',
  ];

  // lista contendo o tamanho das imagens
  final List<int> _sizes = <int>[100, 250];

  // lista contendo os titulos de cada marker
  final List<String> _titles = <String>[
    'Casa Daniel',
    'IFPI',
  ];

  // lista contendo os marcadores
  final List<Marker> _markers = <Marker>[];

  // metodo para carregar as imagens
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();

    /* 
    Resumindo o processo acima:

    1. Recebe o caminho da imagem e o tamanho desejado
    2. Cria um ByteData a partir do caminho da imagem
    3. Cria um codec para decodificar a imagem
    4. Cria um FrameInfo para obter a imagem decodificada
    5. Cria um Uint8List a partir da imagem decodificada
    6. Retorna o Uint8List
    */
  }

  // lista contendo as latitudes e longitudes
  final List<LatLng> _latLen = <LatLng>[
    const LatLng(-5.093708656214135, -42.75412754927936),
    const LatLng(-5.088408, -42.81065),
  ];

  // metodo para pedir permissão de localização, é utilizado apenas para exibir a localização no mapa
  void requestPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }

    var permission = await Geolocator.isLocationServiceEnabled();

    if (permission) {
      // verifica se a permissão foi aceita
      Position locAtual = await Geolocator.getCurrentPosition();

      setState(() {
        _controller.future.then((GoogleMapController controller) {
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(locAtual.latitude, locAtual.longitude),
              zoom: 18,
            ),
          ));
        });
      });
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  // Metodo responsável por carregar os marcadores
  loadData() async {
    for (int i = 0; i < images.length; i++) {
      final Uint8List markIcons = await getImages(images[i], _sizes[i]);
      // makers added according to index
      _markers.add(Marker(
        markerId: MarkerId(i.toString()),
        // obtem a imagem
        icon: BitmapDescriptor.fromBytes(markIcons),
        // Obtem a latitude e longitude
        position: _latLen[i],
        infoWindow: InfoWindow(
          // obtem o titulo do marcador
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
    );
  }

  // para adicionar um evento para que se adicione um marcador ao clicar
  // no mapa

  // Metodo para adicionar o marcador no click
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
