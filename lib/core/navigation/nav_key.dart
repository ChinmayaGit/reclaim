import 'package:flutter/material.dart';

/// Single global navigator key used by GoRouter and the notification service
/// for programmatic navigation from outside the widget tree.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
