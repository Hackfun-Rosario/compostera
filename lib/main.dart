import 'package:flutter/material.dart';

import 'api_compostera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semillero de ideas de Hackfun',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  List<Map<String, dynamic>> _ideas = [];

  @override
  void initState() {
    super.initState();
    _fetchIdeas();
  }

  Future<void> _fetchIdeas() async {
    _ideas = await ApiCompostera.getIdeas();
    setState(() {});
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ApiCompostera.createIdea({
        'nombre': _tituloController.text,
        'descripcion': _descripcionController.text,
      });
      _formKey.currentState!.reset();
      await _fetchIdeas();
      await showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              content: const Text('Idea guardada!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final confirm = await showDialog<bool>(
      //       context: context,
      //       builder:
      //           (context) => AlertDialog(
      //             title: const Text('Confirmación'),
      //             content: const Text('¿Querés borrar todas las ideas?'),
      //             actions: [
      //               TextButton(
      //                 onPressed: () => Navigator.of(context).pop(false),
      //                 child: const Text('No'),
      //               ),
      //               TextButton(
      //                 onPressed: () => Navigator.of(context).pop(true),
      //                 child: const Text('Sí'),
      //               ),
      //             ],
      //           ),
      //     );
      //     if (confirm == true) {
      //       await ApiCompostera.deleteAllIdeas();
      //       await showDialog<void>(
      //         context: context,
      //         builder: (context) => AlertDialog(
      //           content: const Text('Todas las ideas han sido borradas'),
      //           actions: [
      //             TextButton(
      //               onPressed: () => Navigator.of(context).pop(),
      //               child: const Text('Cerrar'),
      //             ),
      //           ],
      //         ),
      //       );
      //       _fetchIdeas();
      //     }
      //   },
      //   tooltip: 'Borrar todas las ideas',
      //   child: const Icon(Icons.delete),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compostera de ideas',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Guardá tus ideas y compartilas con la comunidad',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Ingrese un título'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 5,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Ingrese una descripción'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    'Ideas guardadas:',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Recargar ideas',
                    onPressed: _fetchIdeas,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    _ideas.isEmpty
                        ? const Text('No hay ideas guardadas.')
                        : ListView.builder(
                          itemCount: _ideas.length,
                          itemBuilder: (context, index) {
                            final idea = _ideas[index];
                            return Card(
                              child: ListTile(
                                title: Text(idea['nombre'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(idea['descripcion'] ?? ''),
                                    if (idea['fecha'] != null)
                                      Text(
                                        '${DateTime.tryParse(idea['fecha'] ?? '')}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                onLongPress: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Confirmación'),
                                          content: const Text(
                                            '¿Querés borrar esta idea?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: const Text('Si'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm == true) {
                                    await ApiCompostera.deleteIdeaById(
                                      idea['id'],
                                    );
                                    await _fetchIdeas();
                                    await showDialog<void>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            content: const Text(
                                              'Idea eliminada!',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                child: const Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
