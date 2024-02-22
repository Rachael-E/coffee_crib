import 'package:coffee_crib/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final _mapViewController = ArcGISMapView.createController();
  var graphicsOverlay = GraphicsOverlay();
  var tempGraphicsOverlay = GraphicsOverlay();

  @override
  void initState() {
    super.initState();

    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISChartedTerritory);
    map.initialViewpoint = Viewpoint.withLatLongScale(
        latitude: 4.671, longitude: -73.765, scale: 10000000);
    _mapViewController.arcGISMap = map;
    _mapViewController.graphicsOverlays.add(graphicsOverlay);
    _mapViewController.graphicsOverlays.add(tempGraphicsOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return ArcGISMapView(
      controllerProvider: () => _mapViewController,
    );
  }

  void changeViewpoint(Geometry extent) {
    var viewPoint = Viewpoint.fromTargetExtent(extent);

    // _mapViewController.setViewpoint(viewPoint);
    _mapViewController.setViewpointAnimated(viewPoint, duration: 1);
  }

  void addToGraphicsOverlay(Geometry geometry) {
    var generatedColor = Random().nextInt(Colors.primaries.length);

    final _borderSymbol = SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: Colors.primaries[generatedColor].withOpacity(1.0),
        width: 5.0);

    final _simpleFillSymbol = SimpleFillSymbol(
        style: SimpleFillSymbolStyle.solid,
        color: Colors.primaries[generatedColor].withOpacity(0.5),
        outline: _borderSymbol);

    final graphic = Graphic(geometry: geometry, symbol: _simpleFillSymbol);
    graphicsOverlay.graphics.add(graphic);
  }
}
