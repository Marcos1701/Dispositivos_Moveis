import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Home",
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _gasController = TextEditingController();
  final TextEditingController _alcController = TextEditingController();
  double _result = 0.0;

  @override
  void dispose() {
    _gasController.dispose();
    _alcController.dispose();
    super.dispose();
  }

  // Método para calcular o valor do álcool dividido pelo valor da gasolina vezes 100
  // se o resultado for menor que 70, o álcool é mais vantajoso
  // se o resultado for maior que 70, a gasolina é mais vantajosa
  double _calculate(double gas, double alc) {
    return (alc / gas) * 100;
  }

  // Método para mostrar o resultado em um AlertDialog
  void _showResult(double result) {
    String message = "";
    if (result < 70) {
      message = "O álcool é mais vantajoso";
    } else if (result > 70) {
      message = "A gasolina é mais vantajosa";
    } else {
      message = "Tanto faz";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Resultado"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gasolina x Alcool",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Gasolina x Alcool",
                  style: TextStyle(fontSize: 20),
                ),
                // Imagem
                const Image(
                    image: AssetImage('assets/images/gasolina-alcool.png'),
                    width: 300,
                    height: 300),
                // TextFields
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _gasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Valor da Gasolina",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _alcController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Valor do Álcool",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // Texto para mostrar o resultado
                Text(
                  _result == 0.0
                      ? ""
                      : "Resultado: ${_result.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20),
                ),
                // Botão
                ElevatedButton(
                  onPressed: () {
                    double gas = double.tryParse(_gasController.text) ?? 0.0;
                    double alc = double.tryParse(_alcController.text) ?? 0.0;
                    double result = _calculate(gas, alc);
                    setState(() {
                      _result = result;
                    });
                    _showResult(result);
                  },
                  style: ButtonStyle(
                    // botão retangular
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  child: const Text("Calcular"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
