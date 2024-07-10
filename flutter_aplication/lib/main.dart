import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? idcontato;
  _openDatabase() async {
    var databasepath = await getDatabasesPath();
    String path = join(databasepath, "banco.db");
    var db =
        await openDatabase(path, version: 1, onCreate: (db, version) async {
      String sql =
          "CREATE TABLE contatos (id INTEGER PRIMARY KEY AUTOINCREMENT, nome VARCHAR)";
      await db.execute(sql);
    });

    return db;
  }

  _deletar_db() async {
    var databasepath = await getDatabasesPath();
    String path = join(databasepath, "banco.db");
    await deleteDatabase(path);
  }

  _salvar() async {
    Database db = await _openDatabase();
    Map<String, dynamic> dadosContato = {'nome': 'Manoel Gomes'};

    // Execute a operação assíncrona e obtenha o resultado.
    int novoId = await db.insert('contatos', dadosContato);

    // Depois que a operação assíncrona é concluída, atualize o estado.
    setState(() {
      idcontato = novoId; // Atualiza o estado de forma síncrona.
    });
    return novoId;
  }

  @override
  void initState() {
    super.initState();
    _deletar_db();
  }

  @override
  Widget build(BuildContext context) {
    //_salvar();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Text('$idcontato'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _salvar,
          tooltip: 'Adicionar Contato',
          child: const Text('Add'),
        ));
  }
}
