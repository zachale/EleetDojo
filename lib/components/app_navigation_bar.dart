import 'package:eleetdojo/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationBar extends StatelessWidget {
  final String currentPath;

  const AppNavigationBar({Key? key, required this.currentPath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            "/learning-map",
            "assets/learning_map.png",
            "Learning Map",
          ),
          _buildNavItem(
            context,
            "/dojo",
            "assets/practice_dojo.png",
            "Practice Dojo",
          ),
          _buildNavItem(context, "/sensei", "assets/sensei.png", "Sensei"),
          _buildNavItem(
            context,
            "/settings",
            "assets/settings.png",
            "Settings",
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String path,
    String iconPath,
    String label,
  ) {
    final bool isSelected = currentPath == path;
    final double iconSize = 64;

    return InkWell(
      onTap: () => context.go(path),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
              color: isSelected ? primary_color : Colors.grey,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
