import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as syspaths;

Future<File?> comprimirImagem(File arquivoOriginal) async {
  try {
    final dir = await syspaths.getTemporaryDirectory();
    final targetPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Método correto na versão atual do pacote
    final result = await FlutterImageCompress.compressAndGetFile(
      arquivoOriginal.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1080,
      minHeight: 1080,
    );

    return result != null ? File(result.path) : null;
  } catch (e) {
    debugPrint('Erro ao comprimir imagem: $e');
    return arquivoOriginal;
  }
}