import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(SkillSwapHubApp());
}

// ==================== Notification Service ====================
class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);
  }

  static Future showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _notifications.show(id, title, body, details);
  }
}

// ==================== User Model ====================
class User {
  final String name;
  final List<String> skillsCanTeach;
  final List<String> skillsWantToLearn;
  int points;
  int level;

  User({
    required this.name,
    required this.skillsCanTeach,
    required this.skillsWantToLearn,
    this.points = 0,
    this.level = 1,
  });

  void addPoints(int p) {
    points += p;
    level = (points ~/ 100) + 1;
  }
}

// ==================== Main App ====================
class SkillSwapHubApp extends StatefulWidget {
  @override
  _SkillSwapHubAppState createState() => _SkillSwapHubAppState();
}

class _SkillSwapHubAppState extends State<SkillSwapHubApp> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    SkillBoardScreen(),
    ChatScreen(),
    ScheduleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SkillSwapHub",
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
      ),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: "Skill Board"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: "Schedule"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

// ==================== Home Screen ====================
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi Sneha 👋",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("What skill do you want to explore today?",
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    List.generate(5, (index) => skillCard("Skill ${index + 1}")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget skillCard(String skill) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: Offset(0, 3))
        ],
      ),
      child: Center(
        child: Text(skill,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ==================== Skill Board Screen ====================
class SkillBoardScreen extends StatefulWidget {
  @override
  _SkillBoardScreenState createState() => _SkillBoardScreenState();
}

class _SkillBoardScreenState extends State<SkillBoardScreen> {
  List<User> users = [
    User(
        name: "Alice",
        skillsCanTeach: ["Flutter"],
        skillsWantToLearn: ["UI Design"],
        points: 50),
    User(
        name: "Bob",
        skillsCanTeach: ["Python"],
        skillsWantToLearn: ["Flutter"],
        points: 120),
    User(
        name: "Charlie",
        skillsCanTeach: ["UI Design"],
        skillsWantToLearn: ["Python"],
        points: 200),
    User(
        name: "Sneha",
        skillsCanTeach: ["AI"],
        skillsWantToLearn: ["Python"],
        points: 80),
  ];

  List<User> getMatchedUsers(User currentUser) {
    return users
        .where((user) =>
            user.name != currentUser.name &&
            user.skillsCanTeach
                .any((skill) => currentUser.skillsWantToLearn.contains(skill)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    User currentUser = users[3]; // Sneha
    List<User> matches = getMatchedUsers(currentUser);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Skill Swap Board",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("AI Suggested Matches",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: matches.length,
                itemBuilder: (context, index) => matchCard(matches[index]),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) => skillPostCard(users[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget matchCard(User user) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: Offset(0, 3))
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(child: Icon(Icons.person)),
            SizedBox(height: 8),
            Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Level ${user.level}"),
          ],
        ),
      ),
    );
  }

  Widget skillPostCard(User user) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.shade200,
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(Icons.person)),
                SizedBox(width: 10),
                Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Text("Can teach: ${user.skillsCanTeach.join(', ')}"),
            Text("Wants to learn: ${user.skillsWantToLearn.join(', ')}"),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.star),
                  onPressed: () {
                    setState(() {
                      user.addPoints(10);
                    });
                  },
                ),
                SizedBox(width: 10),
                Icon(Icons.chat_bubble_outline),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ==================== Chat Screen ====================
class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text("Chat",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) =>
                  chatBubble(index % 2 == 0, "Message ${index + 1}"),
            ),
          ),
          chatInput(),
        ],
      ),
    );
  }

  Widget chatBubble(bool isMe, String message) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message),
      ),
    );
  }

  Widget chatInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type a message",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          CircleAvatar(child: Icon(Icons.send)),
        ],
      ),
    );
  }
}

// ==================== Schedule Screen ====================
class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Schedule",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) =>
                  _selectedDay != null && isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                NotificationService.showNotification(
                  id: 1,
                  title: "Session Scheduled",
                  body:
                      "You picked ${selectedDay.toLocal().toString().split(' ')[0]}",
                );
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                    color: Colors.purple, shape: BoxShape.circle),
                todayDecoration:
                    BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Profile Screen ====================
class ProfileScreen extends StatelessWidget {
  final User currentUser = User(
    name: "Sneha",
    skillsCanTeach: ["AI", "Flutter"],
    skillsWantToLearn: ["Python", "UI Design"],
    points: 80,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            SizedBox(height: 16),
            Text(currentUser.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Learning & Teaching Skills",
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: (currentUser.points % 100) / 100,
              minHeight: 10,
              color: Colors.blueAccent,
              backgroundColor: Colors.grey.shade300,
            ),
            SizedBox(height: 8),
            Text("Level ${currentUser.level} | Points: ${currentUser.points}"),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: currentUser.skillsCanTeach
                  .map((skill) => skillChip(skill))
                  .toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24))),
            )
          ],
        ),
      ),
    );
  }

  Widget skillChip(String skill) {
    return Chip(
      label: Text(skill),
      backgroundColor: Colors.blue[100],
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
