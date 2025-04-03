import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonMapPage extends StatelessWidget {
  final dynamic mapData;
  const LessonMapPage({super.key, required this.mapData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Map'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 116.0),
        child: Center(
          child: _buildLearningMap(context, mapData),
        ),
      ),
    );
  }

  Widget _buildLearningMap(BuildContext context, List<Map<String, dynamic>> nodes) {
    List<Widget> mapWidgets = [];
    for (int i = 0; i < nodes.length; i++) {
      mapWidgets.add(_buildNode(context, nodes[i]));
      if (i < nodes.length - 1) {
        mapWidgets.add(_buildArrow());
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: mapWidgets,
    );
  }

  Widget _buildNode(BuildContext context, Map<String, dynamic> node) {
    return GestureDetector(
      onTap: () {
        context.go('/learning-map/${node['id']}');
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          node['name'],
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildArrow() {
    return Icon(
      Icons.arrow_downward,
      size: 32.0,
      color: Colors.grey,
    );
  }
}
