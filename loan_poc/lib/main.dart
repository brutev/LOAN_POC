import 'package:flutter/material.dart';
import 'screens/dynamic_form_screen.dart';

void main() {
  runApp(const LoanPOCApp());
}

class LoanPOCApp extends StatelessWidget {
  const LoanPOCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Origination POC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open Applicant KYC POC'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DynamicFormScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
