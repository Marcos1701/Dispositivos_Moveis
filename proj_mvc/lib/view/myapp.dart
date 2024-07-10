import 'package:flutter/material.dart';
import 'package:proj_mvc/model/classmodel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ItemModels item = ItemModels(name: 'Marcos', check: false);

  void _changeCheck() {
    setState(() {
      item.changeCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Olá ${item.getName}",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20)),
            Text('Check = ${item.getCheck}',
                style: // Theme.of(context).textTheme.headlineMedium,
                    TextStyle(
                        color: item.getCheck ? Colors.green : Colors.red,
                        fontSize: 30)),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 216, 202, 202),
      floatingActionButton: FloatingActionButton(
        onPressed: _changeCheck,
        tooltip: 'swap check',
        // icone de alteração
        child: const Icon(Icons.swap_horiz_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
