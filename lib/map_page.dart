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

class CountryColorManager {
  final Set<Color> _usedColors = {};

  Color getUniqueColor() {
    Color color;
    do {
      color =
          Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    } while (_usedColors.contains(color));

    _usedColors.add(color);
    return color;
  }
}

class MapPageState extends State<MapPage> {
  final _mapViewController = ArcGISMapView.createController();
  var graphicsOverlay = GraphicsOverlay();

  @override
  void initState() {
    super.initState();

    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic);
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
        changeViewpoint(expandedEnvelope(graphic));
      }
    }
  }

  Envelope expandedEnvelope(Graphic graphic) {
    var envelopeBuilder =
        EnvelopeBuilder.fromEnvelope(graphic.geometry!.extent);
    envelopeBuilder.expandBy(1.2);

    return envelopeBuilder.toGeometry().extent;
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
      changeViewpoint(expandedEnvelope(graphic));

      double countryBagsProducedDouble =
          double.parse(graphic.attributes['coffeeCountryBags']);
      var formatter = NumberFormat('#,###,000');
      final countryBagsProduced = formatter.format(countryBagsProducedDouble);
      final countryName = graphic.attributes['name'];

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
  }

  void changeViewpoint(Geometry extent) {
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
        style: SimpleLineSymbolStyle.solid, color: Colors.black, width: 1.0);

    final simpleFillSymbol = SimpleFillSymbol(
        style: SimpleFillSymbolStyle.solid,
        color: generatedColor.withOpacity(0.5),
        outline: borderSymbol);

    final graphic = Graphic(geometry: geometry, symbol: simpleFillSymbol);

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

class CustomAlertDialog extends StatelessWidget {
  final String countryName;
  final String countryBagsProduced;

  CustomAlertDialog({required this.countryName, required this.countryBagsProduced});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
      ),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/coffee_gradient.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                countryName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '$countryName produces $countryBagsProduced bags of coffee annually.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
