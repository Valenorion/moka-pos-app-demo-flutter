import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'moka_theme.dart';
import 'splash_screen.dart';

void main() async {
  // Wajib ditambahkan agar aplikasi tidak crash di versi Release (.apk)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MokaApp());
}

class MokaApp extends StatelessWidget {
  const MokaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOKA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: MokaColors.white,
        textTheme: GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}
