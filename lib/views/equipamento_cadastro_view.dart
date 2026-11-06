import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EquipamentoCadastroView extends StatefulWidget {
  const EquipamentoCadastroView({super.key});

  @override
  State<EquipamentoCadastroView> createState() => _EquipamentoCadastroViewState();
}

class _EquipamentoCadastroViewState extends State<EquipamentoCadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  // Lista para armazenar múltiplas imagens
  final List<File> _imagensSelecionadas = [];
  bool _isLoading = false;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // Escolher entre Câmera ou Galeria para adicionar fotos
  Future<void> _adicionarImagens() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Tirar Foto com a Câmera'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                if (pickedFile != null) {
                  setState(() {
                    _imagensSelecionadas.add(File(pickedFile.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Escolher da Galeria (várias fotos)'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final pickedFiles = await picker.pickMultiImage(imageQuality: 70);
                if (pickedFiles.isNotEmpty) {
                  setState(() {
                    for (var file in pickedFiles) {
                      _imagensSelecionadas.add(File(file.path));
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarEquipamento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Insere e recupera o ID gerado corretamente
      final response = await _supabase.from('equipamentos').insert({
        'nome': _nomeController.text.trim(),
        'codigo': _codigoController.text.trim(),
        'descricao': _descricaoController.text.trim(),
      }).select('id').single();

      final equipamentoId = response['id'];

      // 2. Faz o upload das fotos e vincula na tabela 'equipamento_fotos'
      for (var imagem in _imagensSelecionadas) {
        final fileName = 'eq_${equipamentoId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        await _supabase.storage.from('equipamentos-fotos').upload(
          fileName, 
          imagem,
          fileOptions: const FileOptions(upsert: true),
        );
        
        final imageUrl = _supabase.storage.from('equipamentos-fotos').getPublicUrl(fileName);

        await _supabase.from('equipamento_fotos').insert({
          'equipamento_id': equipamentoId,
          'foto_url': imageUrl,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipamento cadastrado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Erro ao Salvar'),
            content: Text('Detalhes:\n$e'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Equipamento'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Fotos do Equipamento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // Grid / Lista Horizontal de Fotos
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Botão para adicionar mais fotos
                    GestureDetector(
                      onTap: _adicionarImagens,
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 30, color: Colors.blue),
                            SizedBox(height: 4),
                            Text('Adicionar', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                    // Miniaturas das fotos selecionadas
                    ..._imagensSelecionadas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(file, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _imagensSelecionadas.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do Equipamento',
                  prefixIcon: const Icon(Icons.devices),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _codigoController,
                decoration: InputDecoration(
                  labelText: 'Código / Patrimônio',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (v) => v == null || v.isEmpty ? 'Informe o código' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição / Localização',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _salvarEquipamento,
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Salvando...' : 'Salvar Equipamento', style: const TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}