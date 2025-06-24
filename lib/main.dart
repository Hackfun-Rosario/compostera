import 'package:flutter/material.dart';

import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semillero de ideas de Hackfun',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
    final ideas = await DBHelper.getIdeas();
    setState(() {
      _ideas = ideas;
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await DBHelper.insertIdea(
        _tituloController.text,
        _descripcionController.text,
        // DateTime.now().toIso8601String(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Idea guardada!')));
      _formKey.currentState!.reset();
      await _fetchIdeas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Compostera de ideas'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await DBHelper.clearIdeas();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todas las ideas han sido borradas')),
          );
          _fetchIdeas();
        },
        tooltip: 'Borrar todas las ideas',
        child: const Icon(Icons.delete),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text(
                'Ideas guardadas:',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                                title: Text(idea['titulo'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(idea['descripcion'] ?? ''),
                                    if (idea['fecha'] != null)
                                      Text(
                                        'Fecha: ${DateTime.tryParse(idea['fecha'] ?? '')?.toLocal().toString().substring(0, 19) ?? ''}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
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
