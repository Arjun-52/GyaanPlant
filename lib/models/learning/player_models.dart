
// DATA MODELS FOR THE COURSE PLAYER


class PlayerCourse {
  final String id;
  final String title;
  final String description;
  final List<PlayerSection> sections;

  PlayerCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.sections,
  });

  factory PlayerCourse.mock(String title) {
    return PlayerCourse(
      id: "course_101",
      title: title,
      description: "Master the fundamentals of software development and algorithm design with this comprehensive step-by-step course.",
      sections: [
        PlayerSection(
          id: "sec_1",
          title: "Getting Started",
          order: 1,
          lessons: [
            PlayerLesson(
              id: "les_1",
              title: "Course Overview & Learning Strategy",
              description: "Welcome to the course! In this lesson, we will outline our journey, map out key outcomes, and discuss the roadmap to success.",
              videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
              durationMins: 12,
              isCompleted: true,
            ),
            PlayerLesson(
              id: "les_2",
              title: "Environment Setup & Hello World",
              description: "Learn how to configure your local IDE, setup debugging tools, and write your very first running program from scratch.",
              videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
              durationMins: 18,
              isCompleted: false,
            ),
          ],
        ),
        PlayerSection(
          id: "sec_2",
          title: "Core Fundamentals",
          order: 2,
          lessons: [
            PlayerLesson(
              id: "les_3",
              title: "Data Types and Memory Allocation",
              description: "Deep dive into primitive data types, reference memory layouts, heap vs stack allocation, and performance optimization.",
              videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
              durationMins: 25,
              isCompleted: false,
            ),
            PlayerLesson(
              id: "les_4",
              title: "Control Flows & Logical Operators",
              description: "Explore advanced looping paradigms, switch statements, short-circuit evaluation, and conditional branching syntax.",
              videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
              durationMins: 15,
              isCompleted: false,
            ),
            PlayerLesson(
              id: "les_5",
              title: "Functions, Parameters, and Scope",
              description: "Learn to design modular, reusable code units. Understand global vs local scoping, return types, and closure mechanics.",
              videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
              durationMins: 20,
              isCompleted: false,
            ),
          ],
        ),
        PlayerSection(
          id: "sec_3",
          title: "Advanced Concepts",
          order: 3,
          lessons: [
            PlayerLesson(
              id: "les_6",
              title: "Introduction to Complexity & Big O",
              description: "An essential architectural primer on Time and Space complexity. Learn to evaluate algorithm efficiency and optimize performance.",
              videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
              durationMins: 30,
              isCompleted: false,
            ),
            PlayerLesson(
              id: "les_7",
              title: "Array Manipulation & Search Mechanics",
              description: "Learn core operations on contiguous data structures, binary search algorithms, sorting complexities, and practical problems.",
              videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
              durationMins: 22,
              isCompleted: false,
            ),
          ],
        ),
      ],
    );
  }
}
  
/// Model representing a Section within a Course.
class PlayerSection {
  final String id;
  final String title;
  final int order;
  final List<PlayerLesson> lessons;

  PlayerSection({
    required this.id,
    required this.title,
    required this.order,
    required this.lessons,
  });
}

/// Model representing an individual Lesson within a Section.
class PlayerLesson {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final int durationMins;
  bool isCompleted;

  PlayerLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.durationMins,
    this.isCompleted = false,
  });
}
