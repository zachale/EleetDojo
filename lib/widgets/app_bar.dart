import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GoAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if (Navigator.canPop(context)) {
            context.pop();
          }
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}