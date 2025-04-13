import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/history_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyBfS8_oxWI6efzQH7FM6rjLh_6DWyXIz_4',
      appId: '1:1026374258645:android:a17e6a8cb01c4a00efb75c',
      messagingSenderId: '1026374258645',
      projectId: 'gen-lib',
    ),
  );
  runApp(LibraryQRApp());
}

class LibraryQRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library QR Lending',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: BottomNavWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BottomNavWrapper extends StatefulWidget {
  @override
  _BottomNavWrapperState createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    QRScannerScreen(),
    AlertsScreen(),
    HistoryScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabTapped,
      ),
    );
  }
}
