import 'package:flutter/material.dart';

/// Global route observer used so pages can react when they become visible
/// again after a pushed route is popped (e.g. refresh data).
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
