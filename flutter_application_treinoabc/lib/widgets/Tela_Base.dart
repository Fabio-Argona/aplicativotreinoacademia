import 'package:flutter/material.dart';
import 'NavBar.dart';
import 'Footer.dart';

class TelaBase extends StatelessWidget {
  final Widget child;
  final String titulo;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const TelaBase({
    required this.child,
    this.titulo = 'Full Performance',
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(title: titulo, actions: actions),
      body: Column(
        children: [
          Expanded(child: child),
          Footer(),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
