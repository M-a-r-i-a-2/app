import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Librería para hacer peticiones HTTP

// CORRECCIÓN: 'async' y 'Future<void>' no son necesarios aquí.
void main() {
  runApp(const ClimaApp()); // Punto de entrada de la app
}

class ClimaApp extends StatelessWidget {
  const ClimaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(), // Pantalla inicial
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
  final TextEditingController _cityCtrl = TextEditingController(
    text: 'Ciudad de México',
  );
  // ⚠️ API Key de OpenWeatherMap (reemplazar con tu propia clave)
  static const String _apiKey = 'ddf3a3c87053951aa1b60d355d8ec8bf';

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _data;

  Future<void> _buscarClima() async {
    FocusScope.of(context).unfocus(); // Cierra el teclado
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
      'units': 'metric', // Métricas → °C
      'lang': 'es', // Respuesta en español
    });

    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _data = json;
        });
      } else {
        String msg = 'Error ${resp.statusCode}';
        try {
          final j = jsonDecode(resp.body);
          if (j is Map && j['message'] is String) msg = j['message'];
        } catch (_) {}
        setState(() {
          _error = 'No se pudo obtener el clima: $msg';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de red: $e'; // Ej. sin Internet
      });
    } finally {
      // MEJORA: Centraliza el cambio del estado de carga.
      // Se ejecutará siempre, ya sea que la petición falle o sea exitosa.
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _data != null;
    String? nombreCiudad;
    String? pais;
    String? descripcion;
    String? icono;
    num? temp;
    num? tempMin;
    num? tempMax;
    num? sensacion;
    num? humedad;

    if (hasData) {
      final d = _data!;
      nombreCiudad = d['name'];
      pais = (d['sys']?['country'])?.toString();
      final weather = (d['weather'] as List?)?.cast<Map<String, dynamic>>();
      if (weather != null && weather.isNotEmpty) {
        descripcion = weather.first['description']?.toString();
        icono = weather.first['icon']?.toString();
      }
      final main = d['main'] as Map<String, dynamic>?;
      temp = main?['temp'];
      tempMin = main?['temp_min'];
      tempMax = main?['temp_max'];
      sensacion = main?['feels_like'];
      humedad = main?['humidity'];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('App del Clima'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Input de ciudad + botón Buscar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _buscarClima(),
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        hintText: 'Ej. Monterrey, Madrid, Tokyo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _loading ? null : _buscarClima,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading)
                const LinearProgressIndicator(), // Indicador de carga
              if (_error != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              // Muestra clima si hay datos, o un mensaje por defecto
              if (hasData)
                _ClimaCard(
                  ciudad: nombreCiudad ?? '',
                  pais: pais ?? '',
                  descripcion: descripcion ?? '',
                  iconCode: icono,
                  temp: temp?.toDouble(),
                  tempMin: tempMin?.toDouble(),
                  tempMax: tempMax?.toDouble(),
                  sensacion: sensacion?.toDouble(),
                  humedad: humedad?.toInt(),
                )
              else if (!_loading && _error == null)
                // MEJORA: Muestra el mensaje inicial solo si no está cargando ni hay error.
                const Expanded(
                  child: Center(
                    child: Text('Busca una ciudad para ver su clima'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget tarjeta para mostrar clima actual
class _ClimaCard extends StatelessWidget {
  final String ciudad;
  final String pais;
  final String descripcion;
  final String? iconCode;
  final double? temp;
  final double? tempMin;
  final double? tempMax;
  final double? sensacion;
  final int? humedad;

  const _ClimaCard({
    required this.ciudad,
    required this.pais,
    required this.descripcion,
    this.iconCode,
    this.temp,
    this.tempMin,
    this.tempMax,
    this.sensacion,
    this.humedad,
  });

  @override
  Widget build(BuildContext context) {
    final iconUrl = iconCode != null
        ? 'https://openweathermap.org/img/wn/$iconCode@4x.png'
        : null;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    '$ciudad${pais.isNotEmpty ? ", $pais" : ""}',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (iconUrl != null)
                    Image.network(iconUrl, width: 120, height: 120),
                  const SizedBox(height: 8),
                  Text(
                    descripcion.isNotEmpty
                        ? (descripcion[0].toUpperCase() +
                              descripcion.substring(1))
                        : '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (temp != null)
                    Text(
                      '${temp!.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (humedad != null)
                        _InfoChip(
                          icon: Icons.water_drop,
                          label: 'Humedad',
                          value: '$humedad%',
                        ),
                      if (sensacion != null)
                        _InfoChip(
                          icon: Icons.thermostat,
                          label: 'Sensación',
                          value: '${sensacion!.toStringAsFixed(1)}°C',
                        ),
                      if (tempMin != null)
                        _InfoChip(
                          icon: Icons.arrow_downward,
                          label: 'Mín',
                          value: '${tempMin!.toStringAsFixed(1)}°C',
                        ),
                      if (tempMax != null)
                        _InfoChip(
                          icon: Icons.arrow_upward,
                          label: 'Máx',
                          value: '${tempMax!.toStringAsFixed(1)}°C',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Chip reutilizable para mostrar pares "Etiqueta: Valor"
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
