import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EquipamentoListaView extends StatefulWidget {
  const EquipamentoListaView({super.key});

  @override
  State<EquipamentoListaView> createState() => _EquipamentoListaViewState();
}

class _EquipamentoListaViewState extends State<EquipamentoListaView> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _equipamentos = [];
  List<dynamic> _equipamentosFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarEquipamentos();
    _searchController.addListener(_filtrarEquipamentos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarEquipamentos() async {
    try {
      setState(() => _isLoading = true);
      
      final response = await _supabase
          .from('equipamentos')
          .select()
          .order('created_at', ascending: false);
      
      setState(() {
        _equipamentos = response as List<dynamic>;
        _equipamentosFiltrados = _equipamentos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar equipamentos: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _filtrarEquipamentos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _equipamentosFiltrados = _equipamentos.where((eq) {
        final nome = eq['nome']?.toString().toLowerCase() ?? '';
        final codigo = eq['codigo']?.toString().toLowerCase() ?? '';
        return nome.contains(query) || codigo.contains(query);
      }).toList();
    });
  }

  void _mostrarOpcoesEquipamento(Map<String, dynamic> equipamento) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                equipamento['nome'] ?? 'Equipamento',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Código: ${equipamento['codigo'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Imprimindo QR Code para: ${equipamento['nome']}')),
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text('Imprimir QR Code'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Fechar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Equipamentos'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar por nome ou código',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _equipamentosFiltrados.isEmpty
                    ? const Center(child: Text('Nenhum equipamento encontrado.'))
                    : RefreshIndicator(
                        onRefresh: _carregarEquipamentos,
                        child: ListView.builder(
                          itemCount: _equipamentosFiltrados.length,
                          itemBuilder: (context, index) {
                            final eq = _equipamentosFiltrados[index] as Map<String, dynamic>;
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 2,
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.devices, color: Colors.white),
                                ),
                                title: Text(eq['nome'] ?? 'Sem Nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Código: ${eq['codigo']?.toString() ?? 'N/A'}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _mostrarOpcoesEquipamento(eq),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}