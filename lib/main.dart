import 'package:flutter/material.dart';
import 'package:protontime/protontime.dart';

import 'api_compostera.dart';
import 'utils.dart';

GlobalKey navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: GlobalKey<NavigatorState>(),
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
    // Utils.showProgressDialog(context: context, text: 'Cargando ideas...');
    _ideas = await ApiCompostera.getIdeas();
    // if (mounted) {
    //   Utils.closeDialog(context: context);
    // }
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
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('Idea guardada!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final passwordController = TextEditingController();
      //     String? password;
      //     final confirm = await showDialog<bool>(
      //       context: context,
      //       builder:
      //           (context) => AlertDialog(
      //             title: const Text('Confirmación'),
      //             content: Column(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [
      //                 const Text('Contraseña para eliminar la idea:'),
      //                 const SizedBox(height: 12),
      //                 TextField(
      //                   controller: passwordController,
      //                   obscureText: true,
      //                   decoration: const InputDecoration(
      //                     labelText: 'Contraseña',
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             actions: [
      //               TextButton(
      //                 onPressed: () => Navigator.of(context).pop(false),
      //                 child: const Text('No'),
      //               ),
      //               TextButton(
      //                 onPressed: () {
      //                   password = passwordController.text;
      //                   Navigator.of(context).pop(true);
      //                 },
      //                 child: const Text('Si'),
      //               ),
      //             ],
      //           ),
      //     );
      //     if (confirm == true && password != null && password!.isNotEmpty) {
      //       await ApiCompostera.deleteAllIdeas(password: password!);
      //       await _fetchIdeas();
      //       ScaffoldMessenger.of(
      //         navigatorKey.currentContext!,
      //       ).showSnackBar(SnackBar(content: Text('Idea eliminada!')));
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
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Compartí tus ideas o inspirate con las de otros :)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
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
                maxLines: 4,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Ingrese una descripción'
                            : null,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _submit, child: const Text('Guardar')),
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
                    onPressed: () => _fetchIdeas(),
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
                                        Protontime.format(
                                          DateTime.tryParse(idea['fecha'])!,
                                          language: 'es',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                onLongPress: () async {
                                  final passwordController =
                                      TextEditingController();
                                  String? password;
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Confirmación'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Contraseña para eliminar la idea:',
                                              ),
                                              const SizedBox(height: 12),
                                              TextField(
                                                controller: passwordController,
                                                obscureText: true,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Contraseña',
                                                    ),
                                              ),
                                            ],
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
                                              onPressed: () {
                                                password =
                                                    passwordController.text;
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text('Si'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm == true &&
                                      password != null &&
                                      password!.isNotEmpty) {
                                    await ApiCompostera.deleteIdeaById(
                                      id: idea['id'],
                                      password: password!,
                                    );
                                    await _fetchIdeas();
                                    ScaffoldMessenger.of(
                                      navigatorKey.currentContext!,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text('Idea eliminada!'),
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
