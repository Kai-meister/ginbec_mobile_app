import 'package:flutter/material.dart';

/// Global navigator key so non-widget code (e.g. Dio interceptors) can navigate.
final appNavigatorKey = GlobalKey<NavigatorState>();