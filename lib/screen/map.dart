import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ClientLocation {
  final double x;
  final double y;

  ClientLocation(this.x, this.y);
}

class MapPage extends StatelessWidget {
  MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ClientLocation;
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(args.x, args.y), // Center the map over London
        initialZoom: 9.2,
        maxZoom: 15,
      ),
      children: [
        TileLayer(
          // Bring your own tiles
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
          userAgentPackageName: 'com.example.app', // Add your app identifier
          // And many more recommended properties!
        ),
        MarkerLayer(markers: [
          Marker(
              point: LatLng(args.x, args.y),
              child:
                  IconButton(onPressed: () {}, icon: Icon(Icons.control_point)))
        ])
      ],
    );
  }
}
