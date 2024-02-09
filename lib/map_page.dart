import 'package:coffee_crib/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapViewController = ArcGISMapView.createController();
  final _map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISChartedTerritory);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Map Page'),
      ),
      body: ArcGISMapView(
        controllerProvider: () => _mapViewController,
        onMapViewReady: onMapViewReady,
      ),
      floatingActionButton: FloatingActionButton(

        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        },
        child: const Icon(Icons.home, color: Colors.white),
      ),
    );
  }

  void onMapViewReady() async {
    _mapViewController.arcGISMap = _map;
  }
}
