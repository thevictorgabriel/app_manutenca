import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização explícita com a URL e a Anon Key do seu projeto Supabase
  await Supabase.initialize(
    url: 'https://uozhefyoqnblinaucmdvi.supabase.co',
    anonKey: 'sb_publishable_llFPND0GCsq0P3p7LUXA7w_6fsdk0Fz', // Cole aqui a sua chave anon publica do Supabase
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