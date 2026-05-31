import 'package:flutter/material.dart';
import 'package:shared_pref_module_8/to_do_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Task 1: Load SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDark') ?? false;
      _userName = prefs.getString('userName') ?? "Ayush";
    });
  }

  // Task 1: Save SharedPreferences
  void changeTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    setState(() => _isDarkMode = isDark);
  }

  void updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ProTasker',
      theme: _isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: HomeScreen(userName: _userName, isDarkMode: _isDarkMode),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;
  final bool isDarkMode;
  const HomeScreen({Key? key, required this.userName, required this.isDarkMode})
    : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const TodoScreen(),
      const NotesScreen(),
      _buildSettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? "To-Do List"
              : _currentIndex == 1
              ? "My Notes"
              : "Settings",
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.check_box), label: "Tasks"),
          NavigationDestination(icon: Icon(Icons.note), label: "Notes"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  // Task 1: Preferences UI
  Widget _buildSettingsScreen() {
    TextEditingController nameController = TextEditingController(
      text: widget.userName,
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, ${widget.userName}!",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: widget.isDarkMode,
                onChanged: (val) => MyApp.of(context).changeTheme(val),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              title: const Text("Change Name"),
              subtitle: TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Enter your name"),
                onSubmitted: (val) => MyApp.of(context).updateName(val),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.save, color: Colors.blue),
                onPressed: () =>
                    MyApp.of(context).updateName(nameController.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
