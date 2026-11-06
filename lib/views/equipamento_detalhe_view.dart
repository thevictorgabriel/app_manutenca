import 'package:flutter/material.dart';

class EquipamentoDetalheView extends StatelessWidget {
  final Map<String, dynamic> equipamento;

  const EquipamentoDetalheView({super.key, required this.equipamento});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> fotos = equipamento['fotos'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(equipamento['nome'] ?? 'Detalhes do Equipamento'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          fotos[index].toString(),
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
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipamento['nome'] ?? 'Sem Nome',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.qr_code, 'Código:', equipamento['codigo']?.toString() ?? 'N/A'),
                    if (equipamento['setor'] != null && equipamento['setor'].toString().isNotEmpty)
                      _buildInfoRow(Icons.business, 'Setor:', equipamento['setor'].toString()),
                    if (equipamento['descricao'] != null && equipamento['descricao'].toString().isNotEmpty)
                      _buildInfoRow(Icons.description, 'Descrição:', equipamento['descricao'].toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
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
                      content: Text('Imprimindo QR Code de ${equipamento['nome']}...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text(
                  'Imprimir QR Code',
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