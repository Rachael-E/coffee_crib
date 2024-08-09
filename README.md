# coffee_crib

A cross platform mobile app for iOS and Android that shows the largest coffee producing countries in the world, built with the [ArcGIS Maps SDK for Flutter beta](https://www.esri.com/arcgis-blog/products/developers/announcements/announcing-arcgis-maps-sdk-for-flutter-beta/).

You can read more about this app and how it was built in the [Mapping where coffee comes from with the Flutter Maps SDK beta](https://www.esri.com/arcgis-blog/products/developers/developers/mapping-coffee-flutter-maps-sdk/) on ArcGIS Blog.

![Mobile app screen showing world map](CoffeeCrib.png)

## Running the app

The app can be run on an iOS or Android simulator or device. 

- Visit [Esri's Early Adopter site](https://earlyadopter.esri.com/enter/) to download the ArcGIS Maps SDK for Flutter package. Follow the instructions to unpack it. 
- You will also need an API Key access token to run this app.
    - Follow the [Create an API Key tutorial](https://developers.arcgis.com/documentation/security-and-authentication/api-key-authentication/tutorials/create-an-api-key/) and copy your generated API Key.
    - Add the new API key directly to `main.dart` (not recommended for production use) or create an environment JSON file that can be loaded with `flutter run --dart-define-from-file=path/to/json/file.json`
    - The JSON file should be of format: `{ "API_KEY": "your_api_key_here"}`
- Clone or download this repository to the same directory as the arcgis_maps_package
- Open the project in VSCode
- Use `flutter pub upgrade` to configure the dependencies
- Use `dart run arcgis_maps install` to install the package
- Ensure a simulator is running or a device is connected to your development machine
- Run or debug the app to launch it

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Data

This app was built using country polygons in GeoJSON format sourced from https://datahub.io/core/geo-countries and modified in ArcGIS Pro to include coffee producing data, averaged from a range of internet data sources. 
