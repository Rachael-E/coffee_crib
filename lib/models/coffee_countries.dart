// To parse this JSON data, do
//
//     final coffeeCountries = coffeeCountriesFromJson(jsonString);

import 'dart:convert';

CoffeeCountries coffeeCountriesDataFromJson(String str) => CoffeeCountries.fromJson(json.decode(str));

String coffeeCountriesToJson(CoffeeCountries data) => json.encode(data.toJson());

class CoffeeCountries {
    String type;
    Crs crs;
    List<CoffeeFeature> features;

    CoffeeCountries({
        required this.type,
        required this.crs,
        required this.features,
    });

    factory CoffeeCountries.fromJson(Map<String, dynamic> json) => CoffeeCountries(
        type: json["type"],
        crs: Crs.fromJson(json["crs"]),
        features: List<CoffeeFeature>.from(json["features"].map((x) => CoffeeFeature.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "crs": crs.toJson(),
        "features": List<dynamic>.from(features.map((x) => x.toJson())),
    };
}

class Crs {
    String type;
    CrsProperties properties;

    Crs({
        required this.type,
        required this.properties,
    });

    factory Crs.fromJson(Map<String, dynamic> json) => Crs(
        type: json["type"],
        properties: CrsProperties.fromJson(json["properties"]),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "properties": properties.toJson(),
    };
}

class CrsProperties {
    String name;

    CrsProperties({
        required this.name,
    });

    factory CrsProperties.fromJson(Map<String, dynamic> json) => CrsProperties(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}

class CoffeeFeature {
    FeatureType type;
    int id;
    CoffeeCountryGeometry geometry;
    FeatureProperties properties;

    CoffeeFeature({
        required this.type,
        required this.id,
        required this.geometry,
        required this.properties,
    });

    factory CoffeeFeature.fromJson(Map<String, dynamic> json) => CoffeeFeature(
        type: featureTypeValues.map[json["type"]]!,
        id: json["id"],
        geometry: CoffeeCountryGeometry.fromJson(json["geometry"]),
        properties: FeatureProperties.fromJson(json["properties"]),
    );

    Map<String, dynamic> toJson() => {
        "type": featureTypeValues.reverse[type],
        "id": id,
        "geometry": geometry.toJson(),
        "properties": properties.toJson(),
    };
}

class CoffeeCountryGeometry {
    GeometryType type;
    List<List<List<dynamic>>> coordinates;

    CoffeeCountryGeometry({
        required this.type,
        required this.coordinates,
    });

    factory CoffeeCountryGeometry.fromJson(Map<String, dynamic> json) => CoffeeCountryGeometry(
        type: geometryTypeValues.map[json["type"]]!,
        coordinates: List<List<List<dynamic>>>.from(json["coordinates"].map((x) => List<List<dynamic>>.from(x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
    );

    Map<String, dynamic> toJson() => {
        "type": geometryTypeValues.reverse[type],
        "coordinates": List<dynamic>.from(coordinates.map((x) => List<dynamic>.from(x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
    };
}

enum GeometryType {
    multiPolygon,
    polygon
}

final geometryTypeValues = EnumValues({
    "MultiPolygon": GeometryType.multiPolygon,
    "Polygon": GeometryType.polygon
});

class FeatureProperties {
    String admin;
    String isoA3;
    int objectId;
    dynamic description;
    String coffeeProduction;

    FeatureProperties({
        required this.admin,
        required this.isoA3,
        required this.objectId,
        required this.description,
        required this.coffeeProduction,
    });

    factory FeatureProperties.fromJson(Map<String, dynamic> json) => FeatureProperties(
        admin: json["ADMIN"],
        isoA3: json["ISO_A3"],
        objectId: json["ObjectId"],
        description: json["Description"],
        coffeeProduction: json["Coffee_Production"],
    );

    Map<String, dynamic> toJson() => {
        "ADMIN": admin,
        "ISO_A3": isoA3,
        "ObjectId": objectId,
        "Description": description,
        "Coffee_Production": coffeeProduction,
    };
}

enum FeatureType {
    feature
}

final featureTypeValues = EnumValues({
    "Feature": FeatureType.feature
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}
