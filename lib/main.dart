import 'package:flutter/material.dart';

// La función main es el punto de partida de todas las aplicaciones Flutter.
void main() {
  runApp(const MyApp());
}

// MyApp es el widget raíz de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Este widget construye la interfaz de usuario principal de la aplicación.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // Esto es el tema de la aplicación.
        // ColorScheme.fromSeed se usa para generar un esquema de colores
        // a partir de un color semilla.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // MyHomePage es la pantalla de inicio de la aplicación.
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// MyHomePage es un widget con estado, lo que significa que su estado puede cambiar.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // Este widget es la página de inicio. Siempre se marca como "final".
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    // setState notifica a Flutter que el estado ha cambiado,
    // haciendo que la UI se vuelva a construir.
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Este método se vuelve a ejecutar cada vez que se llama a setState.
    return Scaffold(
      appBar: AppBar(
        // El tema se usa aquí para establecer el color de fondo de la AppBar.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // El título de la AppBar se toma del objeto MyHomePage.
        title: Text(widget.title),
      ),
      body: Center(
        // Center es un widget de diseño que centra a su hijo.
        child: Column(
          // Column organiza sus hijos en una columna vertical.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // Esta coma final hace que el formateo automático sea más agradable.
    );
  }
}
