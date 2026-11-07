import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EquipamentoDetalheView extends StatelessWidget {
  final Map<String, dynamic> equipamento;

  const EquipamentoDetalheView({super.key, required this.equipamento});

  // Função para tratar fotos vindas do Supabase (pode vir como List ou String única)
  List<String> _obterListaFotos() {
    final fotosData = equipamento['fotos'];
    if (fotosData == null) return [];
    if (fotosData is List) {
      return fotosData.map((e) => e.toString()).toList();
    }
    if (fotosData is String && fotosData.isNotEmpty) {
      return [fotosData];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final fotos = _obterListaFotos();
    final codigoEquipamento = equipamento['codigo']?.toString() ?? 'N/A';
    final nomeEquipamento = equipamento['nome'] ?? 'Equipamento';

    return Scaffold(
      appBar: AppBar(
        title: Text(nomeEquipamento),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galeria de Fotos do Equipamento
            if (fotos.isNotEmpty) ...[
              const Text(
                'Fotos do Equipamento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fotos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          fotos[index],
                          width: 260,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 260,
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Cartão de Informações
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeEquipamento,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.qr_code, 'Código:', codigoEquipamento),
                    if (equipamento['setor'] != null)
                      _buildInfoRow(Icons.business, 'Setor:', equipamento['setor'].toString()),
                    if (equipamento['descricao'] != null)
                      _buildInfoRow(Icons.description, 'Descrição:', equipamento['descricao'].toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seção do QR Code Visível na Tela
            Center(
              child: Column(
                children: [
                  const Text(
                    'QR Code do Equipamento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: QrImageView(
                      data: codigoEquipamento,
                      version: QrVersions.auto,
                      size: 180.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão Baixar QR Code
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('QR Code de "$nomeEquipamento" gerado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text(
                  'Baixar QR Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.blue[800]),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87))),
        ],
      ),
    );
  }
}