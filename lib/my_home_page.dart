import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:coffee_crib/models/country_color_manager.dart';
import 'package:coffee_crib/widgets/custom_alert_dialog.dart';
import 'package:coffee_crib/widgets/custom_drawer.dart';
import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:coffee_crib/widgets/custom_floating_action_button.dart';
import 'package:coffee_crib/widgets/custom_sliding_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.coffeeFeatures});
  final List<CoffeeFeature> coffeeFeatures;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _mapViewController = ArcGISMapView.createController();
  final _graphicsOverlay = GraphicsOverlay();

  static const _appBarColor = Color.fromARGB(255, 112, 137, 112);
  static const _fabColor = Color.fromARGB(255, 233, 223, 221);
  final _borderSymbol = SimpleLineSymbol(
      style: SimpleLineSymbolStyle.solid, color: Colors.black, width: 1.0);
  final _colorManager = CountryColorManager();
  final _numberFormatter = NumberFormat('#,###,000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        foregroundColor: Colors.white,
        title: const Text("Coffee Countries"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(color: _appBarColor),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onTap: _selectGraphic,
            onMapViewReady: _onMapViewReady,
          ),
          CustomFloatingActionButton(mapViewController: _mapViewController),
          CustomSlidingUpPanel(
            coffeeFeatures: widget.coffeeFeatures,
            zoomToCountryCallback: _zoomToCountry,
          ),
        ],
      ),
    );
  }

  void _onMapViewReady() {
    _displayCoffeeCountriesOnMapAsGraphics();

    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic)
      ..initialViewpoint = Viewpoint.withLatLongScale(
          latitude: 4.671, longitude: -73.765, scale: 100000000);

    _mapViewController.arcGISMap = map;
    _mapViewController.graphicsOverlays.add(_graphicsOverlay);
  }

  void _selectGraphic(Offset localPosition) async {
    final result = await _mapViewController.identifyGraphicsOverlay(
      _graphicsOverlay,
      screenPoint: localPosition,
      tolerance: 22,
    );

    if (result.graphics.isEmpty || !mounted) return;

    final graphic = result.graphics.first;
    if (graphic.geometry != null) {
      _mapViewController.setViewpointAnimated(
          Viewpoint.fromTargetExtent(_expandedEnvelope(graphic.geometry!)),
          duration: 1);
    }

    final countryBagsProducedDouble =
        double.parse(graphic.attributes['coffeeBagsProduced']);
    final countryBagsProduced =
        _numberFormatter.format(countryBagsProducedDouble);
    final countryName = graphic.attributes['countryName'];

    _showCustomDialog(countryName, countryBagsProduced);
  }

  void _zoomToCountry(CoffeeFeature feature) {
    if (_graphicsOverlay.graphics.isEmpty) return;
    final geometry = _graphicsOverlay.graphics
        .firstWhere((graphic) =>
            graphic.attributes['countryName'] == feature.properties.admin)
        .geometry!;
    _mapViewController.setViewpointAnimated(
        Viewpoint.fromTargetExtent(_expandedEnvelope(geometry)),
        duration: 1);
  }

  void _displayCoffeeCountriesOnMapAsGraphics() {
    for (final coffeeCountry in widget.coffeeFeatures) {
      final geometry = _getFeatureGeometry(coffeeCountry);
      if (geometry != null) {
        _createAndDisplayGraphic(geometry, coffeeCountry);
      }
    }
  }

  void _createAndDisplayGraphic(
      Geometry geometry, CoffeeFeature coffeeFeature) {
    final simpleFillSymbol = SimpleFillSymbol(
      style: SimpleFillSymbolStyle.solid,
      color: _colorManager.getUniqueColor(),
      outline: _borderSymbol,
    );

    final graphic = Graphic(geometry: geometry, symbol: simpleFillSymbol);

    graphic.attributes.addAll({
      'coffeeBagsProduced': coffeeFeature.properties.coffeeProduction,
      'countryName': coffeeFeature.properties.admin,
    });

    _graphicsOverlay.graphics.add(graphic);
  }

  Geometry? _getFeatureGeometry(CoffeeFeature feature) {
    final coffeeFeatureCoordinatesList = feature.geometry.coordinates;
    Geometry? polygon;

    if (feature.geometry.type == CountryGeometryType.polygon) {
      final polygonBuilder =
          PolygonBuilder.fromSpatialReference(SpatialReference.wgs84);
      // if country is a single part polygon
      for (final coordinates in coffeeFeatureCoordinatesList[0]) {
        final lat = coordinates[0];
        final long = coordinates[1];
        polygonBuilder.addPoint(
          ArcGISPoint(
            x: lat,
            y: long,
            spatialReference: SpatialReference.wgs84,
          ),
        );
      }
      polygon = polygonBuilder.toGeometry();
    } else if (feature.geometry.type == CountryGeometryType.multiPolygon) {
      final polygonBuilderFromParts =
          PolygonBuilder.fromSpatialReference(SpatialReference.wgs84);
      // if country is a multipart polygon
      for (final part in coffeeFeatureCoordinatesList) {
        final mutablePart =
            MutablePart.withSpatialReference(SpatialReference.wgs84);
        for (final list in part) {
          for (final coordinates in list) {
            final lat = coordinates[0];
            final long = coordinates[1];
            mutablePart.addPoint(
              ArcGISPoint(
                x: lat,
                y: long,
                spatialReference: SpatialReference.wgs84,
              ),
            );
          }
        }
        polygonBuilderFromParts.parts.addPart(mutablePart: mutablePart);
      }
      polygon = polygonBuilderFromParts.toGeometry();
    }

    return polygon;
  }

  Geometry _expandedEnvelope(Geometry geometry) {
    final envelopeBuilder = EnvelopeBuilder.fromEnvelope(geometry.extent)
      ..expandBy(1.2);

    return envelopeBuilder.extent;
  }

  void _showCustomDialog(String countryName, String countryBagsProduced) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          countryName: countryName,
          countryBagsProduced: countryBagsProduced,
        );
      },
    );
  }
}
