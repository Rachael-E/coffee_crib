import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arcgis_maps/arcgis_maps.dart';

// Define MapModel to store the loaded ArcGISMap
class MapModel extends ChangeNotifier {
  ArcGISMap? _map;
  ArcGISMap? get map => _map;

  void setMap(ArcGISMap map) {
    print('set map');
    _map = map;
    notifyListeners();
  }
}

class MapPage2 extends StatefulWidget {
  MapPage2({Key? key}) : super(key: key);

  @override
  State<MapPage2> createState() => MapPage2State();
}

class MapPage2State extends State<MapPage2> {
  final _mapViewController = ArcGISMapView.createController();

  ArcGISMap? _map;

 @override
  void initState() {
    super.initState();
    _map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISChartedTerritory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Map Page'),
      ),
      body: Consumer<MapModel>(
        builder: (context, mapModel, child) {
          print('in consumer');
          return 
          // mapModel.map == null ? 
          ArcGISMapView(
                  controllerProvider: () => _mapViewController,
                  onMapViewReady: () => onMapViewReady(context, mapModel),
                );
              // : 
              const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.pop(context);
          
        },
        child: const Icon(Icons.home, color: Colors.white),
      ),
    );
  }

  void onMapViewReady(BuildContext context, MapModel mapModel) async {

    try {      
      print('onMapViewReady called');
  ArcGISMap? map = mapModel.map;
  if (map != null) {
    // Use the map as needed
    
    print('Map ready: $map' + '$map.$hashCode');
    print('Mapview hash: $_mapViewController.$hashCode');
  } else {
    _mapViewController.arcGISMap = _map;
    mapModel.setMap(_map!); // Store the loaded map in the MapModel
    print('Map is not loaded yet');
  }
  
  } catch (e) {
    print('Error in onMapViewReady: $e');
  }

    // _mapViewController.arcGISMap = _map;
    // mapModel.setMap(_map); // Store the loaded map in the MapModel
  }
}
