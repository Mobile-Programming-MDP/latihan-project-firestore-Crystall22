import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final String? lat;
  final String? lng;
  const MapScreen(this.lat, this.lng, {super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(
          double.parse(widget.lat.toString()),
          double.parse(widget.lng.toString()),
        ),
        initialZoom: 9.2,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.notes',
        ),
        MarkerLayer(markers: [
          Marker(
            point: LatLng(
              double.parse(widget.lat.toString()),
              double.parse(widget.lng.toString()),
            ),
            child: const Icon(
              Icons.location_city,
              color: Colors.red,
              size: 32,
            ),
          ),
        ]),
        // RichAttributionWidget(
        //   attributions: [
        //     TextSourceAttribution(
        //       'OpenStreetMap contributors',
        //       onTap: () =>
        //           launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
