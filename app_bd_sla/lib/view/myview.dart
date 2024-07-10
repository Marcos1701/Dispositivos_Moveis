import 'package:flutter/material.dart';
import 'package:new_app/model/person.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // controlador da tab
  late TabController _tabController;
  // lista de pessoas
  List<Person> _list = [];
  // controlador do login
  late TextEditingController _controllerNome = TextEditingController();
  late TextEditingController _controllerEmail = TextEditingController();
  late TextEditingController _controllerSenha = TextEditingController();

  // usuario selecionado
  late Person? _selectedPerson;

  // validar campos e exibir balão de erro
  _validarCampos(BuildContext context) {
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (nome.isNotEmpty) {
      if (email.isNotEmpty) {
        if (email.contains("@")) {
          if (senha.isNotEmpty) {
            _salvar(nome, email, senha, context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Preencha a senha!"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Preencha o email corretamente!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Preencha o email!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha o nome!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _openDatabase() async {
    var databasepath = await getDatabasesPath();
    String path = join(databasepath, "banco.db");
    var db =
        await openDatabase(path, version: 1, onCreate: (db, version) async {
      String sql =
          "CREATE TABLE Usuarios (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, email TEXT, senha TEXT)";
      await db.execute(sql);
    });

    return db;
  }

  _deletar_db() async {
    var databasepath = await getDatabasesPath();
    String path = join(databasepath, "banco.db");
    await deleteDatabase(path);
  }

  _salvar(String nome, String email, String senha, BuildContext context) async {
    try {
      Database db = await _openDatabase();
      Map<String, dynamic> dadosUsuario = {
        "nome": nome,
        "email": email,
        "senha": senha
      };
      // int id = await db.insert("Usuarios", dadosUsuario);
      await db.insert("Usuarios", dadosUsuario);
      // print("Salvo: $id");
      await _listar();
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Usuário salvo com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      });
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao salvar usuário!"),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  _listar() async {
    Database db = await _openDatabase();
    String sql = "SELECT * FROM Usuarios";
    List usuarios = await db.rawQuery(sql);
    _list.clear();
    for (var usuario in usuarios) {
      Person p = Person(
          name: usuario['nome'],
          email: usuario['email'],
          senha: usuario['senha']);
      _list.add(p);
    }
    setState(() {});
  }

  _toogleSelected(int index) {
    for (int i = 0; i < _list.length; i++) {
      _list[i].selected = false;
    }
    _list[index].toggleSelected();
    setState(() {
      _selectedPerson = _list[index];
    });
  }

  Person _getSelected(BuildContext context) {
    for (int i = 0; i < _list.length; i++) {
      if (_list[i].selected) {
        return _list[i];
      }
    }

    // If no user is selected and there's a Scaffold ancestor
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Nenhum usuário selecionado!"),
          backgroundColor: Colors.red,
        ),
      );
    }

    // If no user is selected and no Scaffold ancestor exists (optional)
    _tabController.animateTo(0); // Navigate to the login tab (optional)
    _list[0].toggleSelected(); // Select the first item (optional)
    setState(() {
      _selectedPerson = _list[0];
    });
    return _list[0];
  }

  @override
  void initState() {
    super.initState();
    _selectedPerson = null;
    _tabController = TabController(length: 3, vsync: this);
    _listar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('TabBar Widget'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                //login tab
                icon: //icone login
                    Icon(Icons.login),
              ),
              Tab(
                // list tab
                icon: Icon(Icons.list),
              ),
              Tab(
                // info user tab
                icon: Icon(Icons.info),
              ),
            ],
          )),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Image(
                      image: AssetImage('assets/images/login.jpg'),
                      width: 250,
                      height: 250),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _controllerNome,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Nome",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                // input fields
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _controllerSenha,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                // button
                Container(
                  // adicionando margin em cima
                  margin: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      _validarCampos(context);

                      // limpar campos
                      _controllerNome.clear();
                      _controllerEmail.clear();
                      _controllerSenha.clear();

                      // mudar para a aba de listagem
                      _tabController.animateTo(1);
                    },
                    style: ButtonStyle(
                      // botão retangular
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.blue, width: 2),
                      ),
                      minimumSize:
                          MaterialStateProperty.all<Size>(const Size(200, 50)),
                      // adicionando sombra
                      elevation: MaterialStateProperty.all<double>(5.0),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue,
                        // deixando o texto como bold
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // lista de pessoas
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _list.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_list[index].name),
                        subtitle: Text(_list[index].email),
                        onTap: () {
                          // mudar para a aba de informações
                          _toogleSelected(index);
                          _tabController.animateTo(2);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Center(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Image(
                      image: AssetImage('assets/images/person.jpg'),
                      width: 150,
                      height: 150),
                ),
                Center(
                    child: SizedBox(
                  width: 600,
                  child: Column(
                    children: [
                      Text(
                        'Nome: ${_getSelected(context).name}',
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        'Email: ${_getSelected(context).email}',
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        'Senha: ${_getSelected(context).senha.isNotEmpty ? _getSelected(context).senha.replaceAll(RegExp(r'.'), '*') : ''}',
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
