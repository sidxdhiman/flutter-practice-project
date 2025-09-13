import 'dart:io';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart'; // <-- helper for Firebase Storage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // required before using Firebase
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const MyApp(),
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
    }
  }

  Widget _welcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.how_to_reg, size: 80, color: Colors.blueGrey),
          const SizedBox(height: 20),
          const Text(
            'Welcome!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => setState(() => _mode = AuthMode.login),
            child: const Text('Login'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _mode = AuthMode.signup),
            child: const Text('Signup'),
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
          const Text(
            'Login',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _user = User(_loginController.text);
                _mode = AuthMode.landing;
              });
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () => setState(() => _mode = AuthMode.signup),
            child: const Text("Go to Signup"),
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
          const Text(
            'Signup',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _signupController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _user = User(_signupController.text);
                _mode = AuthMode.landing;
              });
            },
            child: const Text('Signup'),
          ),
          TextButton(
            onPressed: () => setState(() => _mode = AuthMode.login),
            child: const Text("Go to Login"),
          ),
        ],
      ),
    );
  }

  Widget _landingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _attendance.isEmpty
            ? const Center(
                child: Text(
                  "No attendance yet.",
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: _attendance.length,
                itemBuilder: (context, idx) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blueGrey),
                    title: Text(_attendance[idx]),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAttendanceOptions,
        icon: const Icon(Icons.add),
        label: const Text("Add Attendance"),
      ),
    );
  }

  void _showAddAttendanceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code_scanner, color: Colors.blueGrey),
            title: const Text("Scan QR Code"),
            onTap: () {
              Navigator.pop(context);
              _scanQRCode();
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blueGrey),
            title: const Text("Manual Entry"),
            onTap: () {
              Navigator.pop(context);
              _manualEntryDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: Colors.blueGrey),
            title: const Text("Upload Attendance"),
            onTap: () {
              Navigator.pop(context);
              _uploadAttendance();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _scanQRCode() async {
    String? scannedCode;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Scan QR Code")),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                scannedCode = barcodes.first.rawValue;
                Navigator.pop(context); // close scanner after first scan
              }
            },
          ),
        ),
      ),
    );

    if (scannedCode != null) {
      setState(() {
        _attendance.insert(0, "QR: $scannedCode");
      });
    }
  }

  void _manualEntryDialog() {
    final badgeController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Manual Attendance"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: badgeController,
              decoration: const InputDecoration(labelText: "Badge No."),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
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
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadAttendance() async {
    if (_attendance.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No attendance to upload')));
      return;
    }

    final content = _attendance.join('\n');
    final userId = _user?.username ?? "unknown";

    try {
      // 1. Create temp file
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/attendance.txt');
      await file.writeAsString(content);

      // 2. Upload to Firebase Storage
      final storageService = StorageService();
      final url = await storageService.uploadAttendanceFile(file, userId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Uploaded ✅ URL: $url')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }
}
