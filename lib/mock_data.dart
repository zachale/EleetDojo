final mockLearningMap = [
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

final mockTopics = [
  {
    'id': 1,
    'name': 'Arrays & Hashing',
    'lessons': [
      {'id': 1, 'name': 'Introduction to Arrays'},
      {'id': 2, 'name': 'Advanced Array Techniques'},
    ],
    'quizzes': [
      {'id': 1, 'name': 'Array Basics Quiz'},
      {'id': 2, 'name': 'Array Advanced Quiz'},
    ],
  },
  {
    'id': 2,
    'name': 'Two Pointers',
    'lessons': [
      {'id': 3, 'name': 'Introduction to Two Pointers'},
      {'id': 4, 'name': 'Two Pointers in Depth'},
    ],
    'quizzes': [
      {'id': 3, 'name': 'Two Pointers Basics Quiz'},
      {'id': 4, 'name': 'Two Pointers Advanced Quiz'},
    ],
  },
];

final mockLessons = [
  {
    'id': 1,
    'name': 'Introduction to Arrays',
    'content': '''
<p>Arrays are a fundamental data structure in computer science. They are used to store multiple values in a single variable, organized in a contiguous block of memory.</p>
<p>Each element in an array can be accessed using its index, starting from 0. Arrays are commonly used for tasks such as storing lists of items, implementing other data structures, and performing mathematical computations.</p>
<p>Example:</p>
<pre>
int[] numbers = {1, 2, 3, 4, 5};
</pre>
<p>In the example above, we have an array of integers containing five elements.</p>
    ''',
  },
  {
    'id': 2,
    'name': 'Advanced Array Techniques',
    'content': '''
<p>Advanced array techniques involve optimizing the use of arrays for performance and solving complex problems. These techniques include:</p>
<ul>
  <li><strong>Two-pointer technique:</strong> A method to solve problems involving pairs of elements in an array, often used for sorting or searching.</li>
  <li><strong>Sliding window:</strong> A technique to find subarrays or subsequences that satisfy certain conditions, commonly used in problems involving sums or averages.</li>
  <li><strong>Binary search on arrays:</strong> A method to efficiently search for an element in a sorted array, reducing the time complexity to O(log n).</li>
  <li><strong>Prefix sums:</strong> A technique to preprocess an array to quickly calculate the sum of any subarray.</li>
  <li><strong>Dynamic programming with arrays:</strong> Using arrays to store intermediate results for optimization problems.</li>
</ul>
<p>These techniques are essential for solving problems efficiently and are widely used in competitive programming and real-world applications.</p>
    ''',
  },
  // ...additional lessons...
];

final mockQuizzes = [
  {
    'id': 1,
    'name': 'Array Basics Quiz',
    'questionIds': [
      1,
      // ...additional questions...
    ],
  },
  {
    'id': 2,
    'name': 'Array Advanced Quiz',
    'questionIds': [
      2,
      // ...additional questions...
    ],
  },
  // ...additional quizzes...
];

final mockQuestions = [
  {
    'question': 'What is an array?',
    'options': ['A', 'B', 'C'],
    'answer': 'A',
    'id': 1,
  },
  {
    'question': 'How do you reverse an array?',
    'options': ['A', 'B', 'C'],
    'answer': 'B',
    'id': 2,
  },
  // ...additional questions...
];