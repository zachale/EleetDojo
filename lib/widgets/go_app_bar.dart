import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String route;
  final String name;
  const GoAppBar({super.key, required this.name, this.route = '/learning-map'});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(name),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          context.go(route);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}