import 'package:flutter/material.dart';
import 'package:langis_mate/widgets/header.dart';
import 'package:langis_mate/widgets/app_drawer.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget child;

  const BaseScreen({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(currentRoute: currentRoute),
      appBar: Header(
        title: title,
        onMenuPressed:     () => _scaffoldKey.currentState?.openDrawer(),
        onProfilePressed:  () => Navigator.pushNamed(context, '/profile'),
        onSettingsPressed: () => Navigator.pushNamed(context, '/settings'),
      ),
      body: child,
    );
  }
}
