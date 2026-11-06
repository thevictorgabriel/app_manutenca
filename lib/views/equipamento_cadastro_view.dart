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
  
  File? _imageFile;
  bool _isLoading = false;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _salvarEquipamento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // Se houver imagem, faz o upload para o Storage do Supabase
      if (_imageFile != null) {
        final fileName = 'eq_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage.from('equipamentos-fotos').upload(fileName, _imageFile!);
        imageUrl = _supabase.storage.from('equipamentos-fotos').getPublicUrl(fileName);
      }

      // Salva os dados na tabela 'equipamentos'
      await _supabase.from('equipamentos').insert({
        'nome': _nomeController.text.trim(),
        'codigo': _codigoController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'imagem_url': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipamento cadastrado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
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
              // Área para foto do equipamento
              Center(
                child: GestureDetector(
                  onTap: _selecionarImagem,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                              SizedBox(height: 8),
                              Text('Tirar Foto', style: TextStyle(fontSize: 12, color: Colors.blue))
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do Equipamento',
                  prefixIcon: const Icon(Icons.devices),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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