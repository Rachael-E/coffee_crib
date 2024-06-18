import 'dart:math';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:coffee_crib/components/custom_alert_dialog.dart';
import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late final _mapViewController = ArcGISMapView.createController();
  final _graphicsOverlay = GraphicsOverlay();

  @override
  void initState() {
    super.initState();

    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic)
      ..initialViewpoint = Viewpoint.withLatLongScale(
          latitude: 4.671, longitude: -73.765, scale: 100000000);

    _mapViewController.arcGISMap = map;
    _mapViewController.graphicsOverlays.add(_graphicsOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return ArcGISMapView(
      controllerProvider: () => _mapViewController,
      onTap: _selectGraphic,
    );
  }

  void zoomToCountry(CoffeeFeature feature) {
    for (var graphic in _graphicsOverlay.graphics) {
      if (feature.properties.admin == graphic.attributes['name']) {
        _changeViewpoint(_expandedEnvelope(graphic));
      }
    }
  }

  Envelope _expandedEnvelope(Graphic graphic) {
    final envelopeBuilder =
        EnvelopeBuilder.fromEnvelope(graphic.geometry!.extent)..expandBy(1.2);

    return envelopeBuilder.toGeometry().extent;
  }

  void _selectGraphic(Offset localPosition) async {
    final result = await _mapViewController.identifyGraphicsOverlay(
      _graphicsOverlay,
      screenPoint: localPosition,
      tolerance: 22,
    );

    if (result.graphics.isEmpty || !mounted) return;

    final graphic = result.graphics.first;
    _changeViewpoint(_expandedEnvelope(graphic));

    final countryBagsProducedDouble =
        double.parse(graphic.attributes['coffeeCountryBags']);
    final formatter = NumberFormat('#,###,000');
    final countryBagsProduced = formatter.format(countryBagsProducedDouble);
    final countryName = graphic.attributes['name'];

    _showCustomDialog(countryName, countryBagsProduced);
  }

  void _showCustomDialog(String countryName, String countryBagsProduced) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          countryName: countryName,
          countryBagsProduced: countryBagsProduced,
        );
      },
    );
  }

  void _changeViewpoint(Geometry extent) {
    var viewPoint = Viewpoint.fromTargetExtent(extent, rotation: 0);
    _mapViewController.setViewpointAnimated(viewPoint, duration: 1);
  }

  void showWorldView() {
    _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(ArcGISPoint(x: 0, y: 0), scale: 100000000),
        duration: 1);
  }

  void addToGraphicsOverlay(Geometry geometry, CoffeeFeature coffeeFeature) {
    var colorManager = CountryColorManager();
    var generatedColor = colorManager.getUniqueColor();

    final borderSymbol = SimpleLineSymbol(
      style: SimpleLineSymbolStyle.solid,
      color: Colors.black,
      width: 1.0,
    );

    final simpleFillSymbol = SimpleFillSymbol(
      style: SimpleFillSymbolStyle.solid,
      color: generatedColor.withOpacity(0.5),
      outline: borderSymbol,
    );

    final graphic = Graphic(geometry: geometry, symbol: simpleFillSymbol);

    graphic.attributes.addAll({
      'coffeeCountryBags': coffeeFeature.properties.coffeeProduction,
      'name': coffeeFeature.properties.admin,
    });

    _graphicsOverlay.graphics.add(graphic);
  }
}

class CountryColorManager {
  final Set<Color> _usedColors = {};
  final Random _random = Random();

  Color getUniqueColor() {
    Color color;
    do {
      color = Color((_random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    } while (_usedColors.contains(color));

    _usedColors.add(color);
    return color;
  }
}
