// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

CoffeeCountries welcomeFromJson(String str) => CoffeeCountries.fromJson(json.decode(str));

String welcomeToJson(CoffeeCountries data) => json.encode(data.toJson());

class CoffeeCountries {
    String type;
    List<CoffeeFeature> features;

    CoffeeCountries({
        required this.type,
        required this.features,
    });

    factory CoffeeCountries.fromJson(Map<String, dynamic> json) => CoffeeCountries(
        type: json["type"],
        features: List<CoffeeFeature>.from(json["features"].map((x) => CoffeeFeature.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "features": List<dynamic>.from(features.map((x) => x.toJson())),
    };
}

class CoffeeFeature {
    FeatureType type;
    Properties properties;
    Geometry geometry;

    CoffeeFeature({
        required this.type,
        required this.properties,
        required this.geometry,
    });

    factory CoffeeFeature.fromJson(Map<String, dynamic> json) => CoffeeFeature(
        type: featureTypeValues.map[json["type"]]!,
        properties: Properties.fromJson(json["properties"]),
        geometry: Geometry.fromJson(json["geometry"]),
    );

    Map<String, dynamic> toJson() => {
        "type": featureTypeValues.reverse[type],
        "properties": properties.toJson(),
        "geometry": geometry.toJson(),
    };
}

class Geometry {
    GeometryType type;
    List<List<List<dynamic>>> coordinates;

    Geometry({
        required this.type,
        required this.coordinates,
    });

    factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: geometryTypeValues.map[json["type"]]!,
        coordinates: List<List<List<dynamic>>>.from(json["coordinates"].map((x) => List<List<dynamic>>.from(x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
    );

    Map<String, dynamic> toJson() => {
        "type": geometryTypeValues.reverse[type],
        "coordinates": List<dynamic>.from(coordinates.map((x) => List<dynamic>.from(x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
    };
}

enum GeometryType {
    MULTI_POLYGON,
    POLYGON
}

final geometryTypeValues = EnumValues({
    "MultiPolygon": GeometryType.MULTI_POLYGON,
    "Polygon": GeometryType.POLYGON
});

class Properties {
    String admin;
    String isoA3;

    Properties({
        required this.admin,
        required this.isoA3,
    });

    factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        admin: json["ADMIN"],
        isoA3: json["ISO_A3"],
    );

    Map<String, dynamic> toJson() => {
        "ADMIN": admin,
        "ISO_A3": isoA3,
    };
}

enum FeatureType {
    FEATURE
}

final featureTypeValues = EnumValues({
    "Feature": FeatureType.FEATURE
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
