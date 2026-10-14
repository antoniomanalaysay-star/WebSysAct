import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
const HomeScreen({super.key});
@override
Widget build(BuildContext context) => Scaffold(
appBar: AppBar(title: const Text('Your System')),
body: Center(child: ElevatedButton(
onPressed: () => Navigator.pushNamed(context, '/login'),
child: const Text('Open Login'),
)),
);
}