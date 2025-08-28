import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: MyApp(), // now your app runs inside MaterialApp
    );
  }
}

class User {
  String username;
  User(this.username);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

enum AuthMode { welcome, login, signup, landing }

class _MyAppState extends State<MyApp> {
  AuthMode _mode = AuthMode.welcome;
  User? _user;
  final List<String> _attendance = [];

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _signupController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildScreen(context));
  }

  Widget _buildScreen(BuildContext context) {
    switch (_mode) {
      case AuthMode.welcome:
        return _welcomeScreen();
      case AuthMode.login:
        return _loginScreen();
      case AuthMode.signup:
        return _signupScreen();
      case AuthMode.landing:
        return _landingScreen();
      default:
        return Container();
    }
  }

  Widget _welcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.how_to_reg, size: 80, color: Colors.indigo),
          SizedBox(height: 20),
          Text(
            'Welcome!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => setState(() => _mode = AuthMode.login),
            child: Text('Login'),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _mode = AuthMode.signup),
            child: Text('Signup'),
          ),
        ],
      ),
    );
  }

  Widget _loginScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _loginController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _user = User(_loginController.text);
                _mode = AuthMode.landing;
              });
            },
            child: Text('Login'),
          ),
          TextButton(
            onPressed: () => setState(() => _mode = AuthMode.signup),
            child: Text('Go to Signup'),
          ),
        ],
      ),
    );
  }

  Widget _signupScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Signup',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _signupController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _user = User(_signupController.text);
                _mode = AuthMode.landing;
              });
            },
            child: Text('Signup'),
          ),
          TextButton(
            onPressed: () => setState(() => _mode = AuthMode.login),
            child: Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _landingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _attendance.isEmpty
            ? Center(
                child: Text(
                  "No attendance yet.",
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: _attendance.length,
                itemBuilder: (context, idx) => Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.indigo),
                    title: Text(_attendance[idx]),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAttendanceOptions,
        icon: Icon(Icons.add),
        label: Text("Add Attendance"),
      ),
    );
  }

  void _showAddAttendanceOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.qr_code_scanner, color: Colors.indigo),
            title: Text("Scan QR Code"),
            onTap: () {
              Navigator.pop(context);
              _scanQRCode();
            },
          ),
          ListTile(
            leading: Icon(Icons.edit, color: Colors.indigo),
            title: Text("Manual Entry"),
            onTap: () {
              Navigator.pop(context);
              _manualEntryDialog();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _scanQRCode() async {
    var scanResult = await BarcodeScanner.scan();
    if (scanResult.type == ResultType.Barcode) {
      setState(() {
        _attendance.insert(0, "QR: ${scanResult.rawContent}");
      });
    }
  }

  void _manualEntryDialog() {
    final badgeController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Manual Attendance"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: badgeController,
              decoration: InputDecoration(
                labelText: "Badge No.",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (badgeController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                setState(() {
                  _attendance.insert(
                    0,
                    "Badge: ${badgeController.text}, Name: ${nameController.text}",
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}
