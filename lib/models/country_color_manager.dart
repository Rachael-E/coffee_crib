import 'dart:math';
import 'dart:ui';

class CountryColorManager {
  final _usedColors = <Color>[];
  final _random = Random();

  Color getUniqueColor() {
    Color color;
    do {
      color = Color((_random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.5);
    } while (_usedColors.contains(color));
    _usedColors.add(color);
    return color;
  }
}