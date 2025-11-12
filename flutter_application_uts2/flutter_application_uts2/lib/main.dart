import 'package:flutter/material.dart';
import 'form_page.dart';
import 'result_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Input Flutter',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});
  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tab == 0 ? 'Form Input Data' : 'Data Mahasiswa')),
      body: _tab == 0 ? const FormPage() : const ResultPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Form'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Result'),
        ],
      ),
    );
  }
}
