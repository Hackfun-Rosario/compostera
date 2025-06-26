import 'dart:developer';

import 'package:compostera/utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:protontime/protontime.dart';
import 'package:responsive_framework/responsive_framework.dart';

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
      builder:
          (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
      title: 'Semillero de ideas de Hackfun',
      // navigatorKey: GlobalKey<NavigatorState>(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
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
  final _aliasController = TextEditingController();

  List<Map<String, dynamic>> _ideas = [];
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    fetchIdeas();

  }

  Future<void> fetchIdeas() async {
    _ideas = await ApiCompostera.getIdeas();
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    Utils.showProgressDialog(context: context);
    if (_tituloController.text.isEmpty) {
      if (!context.mounted) return;
      mySnackbar(context, 'El título es obligatorio');
      Utils.closeDialog(context: context);
      return;
    }
    try {
      await ApiCompostera.createIdea({
        'nombre': _tituloController.text,
        'descripcion': _descripcionController.text,
        'alias': _aliasController.text,
      });
      _formKey.currentState!.reset();
      _tituloController.text = '';
      _descripcionController.text = '';
      _aliasController.text = '';
      Future.delayed(Duration(seconds: 1)).then((_) async {
        await fetchIdeas();
        if (!context.mounted) return;
        mySnackbar(context, 'Idea plantada!');
      });
    } catch (e) {
      log(e.toString());
      if (!context.mounted) return;
      mySnackbar(context, 'Algo salió mal...');
    } finally {
      if (context.mounted) {
        Utils.closeDialog(context: context);
      }
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
      //       await fetchIdeas();
      //     }
      //   },
      //   tooltip: 'Borrar todas las ideas',
      //   child: const Icon(Icons.delete),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            ResponsiveBreakpoints.of(context).isDesktop
                ? Flexible(flex: 2, child: SizedBox.expand())
                : SizedBox.shrink(),
            Flexible(
              flex: 6,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compostera de ideas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text('Version: ${packageInfo?.version}'),
                    const SizedBox(height: 12),
                    Text(
                      'Un lugar para compartir ideas y buscar inspiración.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Nueva idea'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _tituloController,
                                    decoration: const InputDecoration(
                                      labelText: 'Título (requerido)',
                                    ),
                                    keyboardType: TextInputType.text,
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _descripcionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Descripción',
                                    ),
                                    maxLines: 3, // Set this
                                    keyboardType: TextInputType.multiline,
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _aliasController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre o alias',
                                    ),
                                    keyboardType: TextInputType.text,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _submit(context).then((_) {
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  },
                                  child: const Text('Plantar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      label: Text('Plantar una idea'),
                      icon: Icon(Icons.add),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text(
                          'Ideas',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Recargar ideas',
                          onPressed: () async {
                            Utils.showProgressDialog(context: context);
                            await fetchIdeas();
                            if (context.mounted) {
                              Utils.closeDialog(context: context);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child:
                          _ideas.isEmpty
                              ? const Text('No hay ideas guardadas.')
                              :ListView.builder(
                                itemCount: _ideas.length,
                                itemBuilder: (context, index) {
                                  final idea = _ideas[index];
                                  return IdeaCard(
                                    idea: idea,
                                    fetchIdeas: fetchIdeas,
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),
            ResponsiveBreakpoints.of(context).isDesktop
                ? Flexible(flex: 2, child: SizedBox.expand())
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class IdeaCard extends StatelessWidget {
  const IdeaCard({super.key, required this.idea, required this.fetchIdeas});

  final Map<String, dynamic> idea;
  final Future<void> Function() fetchIdeas;

  @override
  Widget build(BuildContext context) {
    final autor = idea['alias'] ?? 'Anónimo';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ListTile(
          leading: Image.asset(
            'assets/leaf.png',
            color: Colors.green,
            width: 25,
          ),
          title: Text(
            idea['nombre'],
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(idea['descripcion'] ?? ''),


              Text(
                'Agregada ${Protontime.format(DateTime.tryParse(idea['fecha'])!, language: 'es')} por $autor',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onLongPress: () async {
            final passwordController = TextEditingController();
            String? password;
            final confirm = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Confirmación'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Contraseña para eliminar la idea:'),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context).pop(false);
                          });
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          password = passwordController.text;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context).pop(true);
                          });
                        },
                        child: const Text('Si'),
                      ),
                    ],
                  ),
            );
            if (confirm == true && password != null && password!.isNotEmpty) {
              await ApiCompostera.deleteIdeaById(
                id: idea['id'],
                password: password!,
              );
              Future.delayed(Duration(seconds: 1)).then((_) async {
                await fetchIdeas();
                if (!context.mounted) return;
                mySnackbar(context, 'Idea eliminada');
              });
            }
          },
        ),
      ),
    );
  }
}

void mySnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white70)),
      backgroundColor: Colors.brown,
    ),
  );
}
