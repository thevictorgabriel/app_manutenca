import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EquipamentoDetalheView extends StatefulWidget {
  final String codigoEquipamento;

  const EquipamentoDetalheView({super.key, required this.codigoEquipamento});

  @override
  State<EquipamentoDetalheView> createState() => _EquipamentoDetalheViewState();
}

class _EquipamentoDetalheViewState extends State<EquipamentoDetalheView> {
  bool _carregando = true;
  Map<String, dynamic>? _equipamentoData;

  @override
  void initState() {
    super.initState();
    _buscarEquipamento();
  }

  Future<void> _buscarEquipamento() async {
    try {
      final response = await Supabase.instance.client
          .from('equipamentos')
          .select()
          .eq('codigo', widget.codigoEquipamento)
          .maybeSingle();

      if (!mounted) return; // Garante que o widget ainda está ativo na tela

      setState(() {
        _equipamentoData = response;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar equipamento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_equipamentoData?['nome'] ?? 'Equipamento'),
        backgroundColor: const Color(0xFF0047AB),
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _equipamentoData == null
              ? const Center(child: Text('Equipamento não encontrado no banco de dados!'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _equipamentoData!['nome'],
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _equipamentoData!['descricao'] ?? 'Sem descrição informada.',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      _botaoManutencao('Manutenção Corretiva', Colors.orange, () {}),
                      const SizedBox(height: 12),
                      _botaoManutencao('Manutenção Preditiva', Colors.blueAccent, () {}),
                      const SizedBox(height: 12),
                      _botaoManutencao('Manutenção Preventiva', Colors.green, () {}),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _botaoManutencao(String texto, Color cor, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: cor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}