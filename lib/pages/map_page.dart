import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonMapPage extends StatelessWidget {
  const LessonMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> nodes = [
      {'name': 'Arrays & Hashing', 'id': 1},
      {'name': 'Two Pointers', 'id': 2},
      {'name': 'Stack', 'id': 3},
      {'name': 'Binary Search', 'id': 4},
      {'name': 'Sliding Window', 'id': 5},
      {'name': 'Linked List', 'id': 6},
      {'name': 'Trees', 'id': 7},
      {'name': 'Tries', 'id': 8},
      {'name': 'Backtracking', 'id': 9},
      {'name': 'Heap / Priority Queue', 'id': 10},
      {'name': 'Graphs', 'id': 11},
      {'name': '1D Dynamic Programming', 'id': 12},
      {'name': 'Intervals', 'id': 13},
      {'name': 'Greedy', 'id': 14},
      {'name': 'Advanced Graphs', 'id': 15},
      {'name': '2D Dynamic Programming', 'id': 16},
      {'name': 'Bit Manipulation', 'id': 17},
      {'name': 'Math & Geometry', 'id': 18},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Map'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: buildLearningMap(context, nodes),
        ),
      ),
    );
  }

  Widget buildLearningMap(BuildContext context, List<Map<String, dynamic>> nodes) {
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
        context.go('/node/${node['id']}');
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
