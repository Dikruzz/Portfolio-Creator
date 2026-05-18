import 'package:flutter/widgets.dart';

class Breakpoints {
  const Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static DeviceClass of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktop) return DeviceClass.desktop;
    if (width >= tablet) return DeviceClass.tablet;
    return DeviceClass.mobile;
  }
}

enum DeviceClass { mobile, tablet, desktop }
