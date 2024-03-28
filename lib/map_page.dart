import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final _mapViewController = ArcGISMapView.createController();
  var graphicsOverlay = GraphicsOverlay();

  @override
  void initState() {
    super.initState();

    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISChartedTerritory);
    map.initialViewpoint = Viewpoint.withLatLongScale(
        latitude: 4.671, longitude: -73.765, scale: 100000000);
    _mapViewController.arcGISMap = map;
    _mapViewController.graphicsOverlays.add(graphicsOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return ArcGISMapView(
      controllerProvider: () => _mapViewController,
      onTap: selectGraphic,
    );
  }

  void zoomToCountry(CoffeeFeature feature) {

    for (var graphic in graphicsOverlay.graphics) {
          if (feature.properties.admin == graphic.attributes['name']) {
            changeViewpoint(graphic.geometry!.extent);
      
    }

    }

  }

  void selectGraphic(Offset localPosition) async {
    final identifyGraphicsOverlayResult =
        await _mapViewController.identifyGraphicsOverlay(
      graphicsOverlay,
      screenPoint: localPosition,
      tolerance: 22,
    );

    if (identifyGraphicsOverlayResult.graphics.isEmpty) return;

    if (context.mounted) {
      final graphic = identifyGraphicsOverlayResult.graphics.first;
      double countryBagsProducedDouble = double.parse(graphic.attributes['coffeeCountryBags']);
      var formatter = NumberFormat('#,###,000');
      final countryBagsProduced = formatter.format(countryBagsProducedDouble);
      final countryName = graphic.attributes['name'];

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(countryName), content: Text('$countryName produces $countryBagsProduced bags of coffee annually.'));
        },
      );
    }
  }

  void showWorldView() {
    _mapViewController.setViewpointAnimated(
      Viewpoint.fromCenter(
        ArcGISPoint(
          x: 0, 
          y: 0
        ), 
        scale: 100000000
        ), 
      duration: 1);
  }

  void changeViewpoint(Geometry extent) {
    var viewPoint = Viewpoint.fromTargetExtent(extent);
    _mapViewController.setViewpointAnimated(viewPoint, duration: 1);
  }

  void addToGraphicsOverlay(Geometry geometry, CoffeeFeature coffeeFeature) {
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

    final coffeeCountryBags = <String, dynamic>{
      'coffeeCountryBags': coffeeFeature.properties.coffeeProduction
    };
    final coffeeCountryName = <String, dynamic>{
      'name': coffeeFeature.properties.admin
    };

    graphic.attributes.addEntries(coffeeCountryBags.entries);
    graphic.attributes.addEntries(coffeeCountryName.entries);

    graphicsOverlay.graphics.add(graphic);
  }
}
