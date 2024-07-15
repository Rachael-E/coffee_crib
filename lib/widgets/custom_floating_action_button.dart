import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton(
      {super.key, required this.mapViewController});

  final ArcGISMapViewController mapViewController;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.1,
      right: 16,
      child: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 233, 223, 221),
        onPressed: () => {
          mapViewController.setViewpointAnimated(
            Viewpoint.fromCenter(
              ArcGISPoint(x: 0, y: 0),
              scale: 100000000,
            ),
            duration: 1,
          )
        },
        child: const Icon(Icons.zoom_out_map, color: Colors.black),
      ),
    );
  }
}