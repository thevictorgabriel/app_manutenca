import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'equipamento_detalhe_view.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isScanned = false;

  Future<void> _buscarEAbriEquipamento(String codigo) async {
    try {
      // Busca o equipamento no Supabase pelo código lido no QR Code
      final response = await _supabase
          .from('equipamentos')
          .select()
          .eq('codigo', codigo)
          .maybeSingle();

      if (!mounted) return;

      if (response != null) {
        // Navega para os detalhes passando o mapa do equipamento encontrado
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EquipamentoDetalheView(equipamento: response),
          ),
        );
      } else {
        setState(() => _isScanned = false); // Permite tentar ler novamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nenhum equipamento encontrado com o código: $codigo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isScanned = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar equipamento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escaneando QR Code'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _isScanned = true;
                  final codigoLido = barcode.rawValue!;
                  _buscarEAbriEquipamento(codigoLido);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              'Aponte a câmera para o QR Code do equipamento',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}