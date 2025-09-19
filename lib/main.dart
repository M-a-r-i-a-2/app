import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ClimaApp());
}

class ClimaApp extends StatelessWidget {
  const ClimaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityCtrl = TextEditingController();

  static const String _apiKey = 'ddf3a3c87053951aa1b60d355d8ec8bf';

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _data;
  String? _ciudadSeleccionada;

  final List<String> _ciudades = [
    'Ixmiquilpan',
    'Monterrey',
    'Bogotá',
    'Medellín',
    'Santo Domingo',
    'Madrid',
    'Buenos Aires',
    'Nueva York',
    'Tokio',
    'Londres',
  ];

  @override
  void initState() {
    super.initState();

    if (_ciudades.isNotEmpty) {
      _ciudadSeleccionada = _ciudades.first;
      _cityCtrl.text = _ciudadSeleccionada!;
      _buscarClima();
    }
  }

  Future<void> _buscarClima() async {
    FocusScope.of(context).unfocus();
    final city = _cityCtrl.text.trim();
    if (city.isEmpty) {
      setState(() => _error = 'Escribe una ciudad.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });

    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'es',
    });

    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _data = json;
        });
      } else {
        final errorJson = jsonDecode(resp.body);
        final errorMessage = errorJson['message'] ?? 'Error desconocido';
        setState(() {
          _error = 'Error: $errorMessage';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de red. Revisa tu conexión a internet.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima App de Maria del Rocio'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // CAMBIO: Se agregó el Dropdown y se ajustó la fila de búsqueda
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _buscarClima(),
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // NUEVO: Dropdown para seleccionar ciudades
                  DropdownButton<String>(
                    value: _ciudadSeleccionada,
                    icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                    underline: Container(height: 2, color: Colors.blueAccent),
                    onChanged: (String? nuevoValor) {
                      if (nuevoValor != null) {
                        setState(() {
                          _ciudadSeleccionada = nuevoValor;
                          _cityCtrl.text = nuevoValor;
                          _buscarClima();
                        });
                      }
                    },
                    items: _ciudades.map<DropdownMenuItem<String>>((
                      String valor,
                    ) {
                      return DropdownMenuItem<String>(
                        value: valor,
                        child: Text(valor),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _buscarClima,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ),
              const SizedBox(height: 16),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
              const SizedBox(height: 16),
              if (_data != null)
                _ClimaCard(data: _data!)
              else if (!_loading && _error == null)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Busca o selecciona una ciudad para ver su clima',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClimaCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ClimaCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // Extracción segura de datos
    final String ciudad = data['name'] ?? 'N/A';
    final String pais = data['sys']?['country'] ?? '';
    final String descripcion = data['weather']?[0]?['description'] ?? 'N/A';
    final String? iconCode = data['weather']?[0]?['icon'];
    final double temp = (data['main']?['temp'] as num?)?.toDouble() ?? 0.0;
    final double tempMin =
        (data['main']?['temp_min'] as num?)?.toDouble() ?? 0.0;
    final double tempMax =
        (data['main']?['temp_max'] as num?)?.toDouble() ?? 0.0;
    final double sensacion =
        (data['main']?['feels_like'] as num?)?.toDouble() ?? 0.0;
    final int humedad = (data['main']?['humidity'] as num?)?.toInt() ?? 0;

    final iconUrl = iconCode != null
        ? 'https://openweathermap.org/img/wn/$iconCode@4x.png'
        : null;

    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$ciudad${pais.isNotEmpty ? ", $pais" : ""}',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (iconUrl != null)
                  Image.network(iconUrl, width: 120, height: 120),
                Text(
                  descripcion.isNotEmpty
                      ? (descripcion[0].toUpperCase() +
                            descripcion.substring(1))
                      : '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  '${temp.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.water_drop,
                      label: 'Humedad',
                      value: '$humedad%',
                    ),
                    _InfoChip(
                      icon: Icons.thermostat,
                      label: 'Sensación',
                      value: '${sensacion.toStringAsFixed(1)}°C',
                    ),
                    _InfoChip(
                      icon: Icons.arrow_downward,
                      label: 'Mín',
                      value: '${tempMin.toStringAsFixed(1)}°C',
                    ),
                    _InfoChip(
                      icon: Icons.arrow_upward,
                      label: 'Máx',
                      value: '${tempMax.toStringAsFixed(1)}°C',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon), label: Text('$label: $value'));
  }
}
