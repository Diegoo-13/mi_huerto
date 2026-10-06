import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HuertoPage(),
    );
  }
}

class HuertoPage extends StatefulWidget {
  const HuertoPage({super.key});

  @override
  State<HuertoPage> createState() => _HuertoPageState();
}

class _HuertoPageState extends State<HuertoPage> {
  final controller = TextEditingController();
  
  // Almacenaremos pares de valores: "Nombre del cultivo | Fecha"
  List<String> cultivos = [];
  
  // Variable temporal para guardar la fecha seleccionada
  DateTime? fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  // Función para abrir el selector de fecha (DatePicker)
  Future<void> seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != fechaSeleccionada) {
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }

  Future<void> agregar() async {
    final texto = controller.text.trim();
    if (texto.isEmpty) {
      return;
    }

    // Formatear la fecha seleccionada o poner un texto por defecto
    String fechaTexto = fechaSeleccionada == null
        ? 'Sin fecha'
        : '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}';

    // Guardamos el cultivo y su fecha separados por un formato legible (ej. Pipe '|')
    final cultivoConFecha = '$texto|$fechaTexto';

    setState(() {
      cultivos.add(cultivoConFecha);
      controller.clear();
      fechaSeleccionada = null; // Reiniciamos la fecha seleccionada
    });
    
    await guardar();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi huerto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nombre del cultivo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            
            // Fila para el botón de fecha y el botón de guardar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => seleccionarFecha(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      fechaSeleccionada == null
                          ? 'Cosecha'
                          : '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: agregar,
                  child: const Text('Guardar'),
                ),
              ],
            ),
            
            const SizedBox(height: 10.0),
            
            Expanded(
              child: ListView.builder(
                itemCount: cultivos.length,
                itemBuilder: (_, i) {
                  // Separamos el texto guardado usando el carácter '|'
                  final partes = cultivos[i].split('|');
                  final nombre = partes[0];
                  final fecha = partes.length > 1 ? partes[1] : 'Sin fecha';

                  return ListTile(
                    leading: const Icon(Icons.eco),
                    title: Text(nombre),
                    subtitle: Text('Cosecha: $fecha'), // Muestra la fecha como subtítulo
                    trailing: IconButton(
                      onPressed: () => eliminar(i),
                      icon: const Icon(Icons.delete),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cultivos = prefs.getStringList('cultivos') ?? [];
    });
  }

  Future<void> guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cultivos', cultivos);
  }

  Future<void> eliminar(int index) async {
    setState(() => cultivos.removeAt(index));
    await guardar();
  }
}