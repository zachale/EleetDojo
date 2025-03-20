import 'package:eleetdojo/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:eleetdojo/main.dart';

final hardcodedData = [
  {
    "name": "Two Sum",
    "difficulty": "Easy",
    "question":
        "Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.",
    "tags": ["Array", "Hash Table"],
    "url": "https://leetcode.com/problems/two-sum/",
  },
  {
    "name": "Longest Substring Without Repeating Characters",
    "difficulty": "Medium",
    "question":
        "Given a string s, find the length of the longest substring without repeating characters.",
    "tags": ["String", "Sliding Window"],
    "url":
        "https://leetcode.com/problems/longest-substring-without-repeating-characters/",
  },
  {
    "name": "Merge Two Sorted Lists",
    "difficulty": "Easy",
    "question":
        "Merge two sorted linked lists and return it as a new sorted list.",
    "tags": ["Linked List", "Recursion"],
    "url": "https://leetcode.com/problems/merge-two-sorted-lists/",
  },
  {
    "name": "Binary Search",
    "difficulty": "Easy",
    "question":
        "Given a sorted array of integers and a target value, return the index of the target if found, or -1 if not found.",
    "tags": ["Binary Search"],
    "url": "https://leetcode.com/problems/binary-search/",
  },
  {
    "name": "LRU Cache",
    "difficulty": "Hard",
    "question":
        "Design a data structure that follows the Least Recently Used (LRU) cache policy.",
    "tags": ["Design", "Hash Table", "Linked List"],
    "url": "https://leetcode.com/problems/lru-cache/",
  },
  {
    "name": "Merge Intervals",
    "difficulty": "Medium",
    "question":
        "Given an array of intervals where intervals[i] = [starti, endi], merge all overlapping intervals.",
    "tags": ["Array", "Sorting"],
    "url": "https://leetcode.com/problems/merge-intervals/",
  },
  {
    "name": "Maximum Subarray",
    "difficulty": "Medium",
    "question":
        "Find the contiguous subarray within an array which has the largest sum.",
    "tags": ["Array", "Dynamic Programming"],
    "url": "https://leetcode.com/problems/maximum-subarray/",
  },
  {
    "name": "Top K Frequent Elements",
    "difficulty": "Medium",
    "question":
        "Given an integer array nums and an integer k, return the k most frequent elements.",
    "tags": ["Heap", "Hash Table"],
    "url": "https://leetcode.com/problems/top-k-frequent-elements/",
  },
  {
    "name": "Valid Parentheses",
    "difficulty": "Easy",
    "question":
        "Given a string containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.",
    "tags": ["Stack", "String"],
    "url": "https://leetcode.com/problems/valid-parentheses/",
  },
  {
    "name": "Word Ladder",
    "difficulty": "Hard",
    "question":
        "Given two words (beginWord and endWord), and a dictionary, find the shortest transformation sequence from beginWord to endWord.",
    "tags": ["Graph", "BFS"],
    "url": "https://leetcode.com/problems/word-ladder/",
  },
];

class DojoPage extends StatefulWidget {
  final AuthService auth_service;

  const DojoPage({super.key, required this.auth_service});

  @override
  _DojoPageState createState() => _DojoPageState();
}

class _DojoPageState extends State<DojoPage> {
  List<Map<String, dynamic>> filteredData = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredData = List.from(hardcodedData);
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query.trim().toLowerCase();
      if (searchQuery.isEmpty) {
        filteredData = List.from(hardcodedData);
      } else {
        List<String> searchWords = searchQuery.split(' ');

        filteredData =
            hardcodedData.where((question) {
              String questionText = question["name"].toString().toLowerCase();
              return searchWords.any((word) => questionText.contains(word));
            }).toList();
      }
    });
  }

  void _getRandomQuestion() {
    if (filteredData.isEmpty) {
      debugPrint("No questions available for random selection.");
      return;
    }

    final random = Random();
    final randomIndex = random.nextInt(filteredData.length);
    final randomQuestion = filteredData[randomIndex];

    debugPrint("Random question: ${randomQuestion["name"]}");
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter Questions"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add your filter options here (for example, Difficulty Filter)
              DropdownButton<String>(
                items:
                    ["Easy", "Medium", "Hard"]
                        .map(
                          (difficulty) => DropdownMenuItem<String>(
                            value: difficulty,
                            child: Text(difficulty),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    filteredData =
                        value == null
                            ? List.from(hardcodedData)
                            : hardcodedData
                                .where(
                                  (question) =>
                                      question["difficulty"].toString() ==
                                      value,
                                )
                                .toList();
                  });
                  Navigator.pop(context);
                },
                hint: const Text('Select Difficulty'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LeetCode Dojo'),
        backgroundColor: background_color,
        foregroundColor: primary_color,
      ),
      body: Stack(
        children: [
          Container(
            color: background_color,
            child: Column(
              children: [
                Expanded(
                  child:
                      filteredData.isEmpty
                          ? const Center(
                            child: Text(
                              'No questions found',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                          : ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final question = filteredData[index];
                              return Card(
                                color: background_color,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: primary_color,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  title: Text(
                                    '${question["name"]}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primary_color,
                                    ),
                                  ),
                                  subtitle: Text(
                                    question["question"],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    debugPrint(
                                      'Question tapped: ${question["name"]}',
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: background_color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: primary_color),
                      cursorColor: primary_color,
                      decoration: InputDecoration(
                        hintText: 'Search questions...',
                        hintStyle: TextStyle(color: primary_color),
                        // prefixIcon: Icon(Icons.search, color: primary_color),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: primary_color),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primary_color,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primary_color),
                        ),
                      ),
                      onChanged: _handleSearch,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.white),
                    onPressed: _getRandomQuestion,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: _openFilterDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
