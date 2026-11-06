import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/home_view.dart'; // Certifique-se de que o caminho para sua HomeView está correto

Future<void> main() async {
  // Obrigatório para inicializar os bindings do Flutter antes do Supabase
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uozhefyoqnblnuucmdvi.supabase.co',
    publishableKey: 'sb_publishable_llFPND0GCsq0P3p7LUXA7w_6fsdk0Fz',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciamento de Equipamentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}