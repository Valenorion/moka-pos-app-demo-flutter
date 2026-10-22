import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_page.dart';
import 'dashboard_page.dart';
import 'moka_theme.dart'; // Menggunakan tema warna konsisten MOKA

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi denyut (pulsing) untuk logo moka.png
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _checkLoginSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Durasi tampil splash screen 3.5 detik
    await Future.delayed(const Duration(milliseconds: 3500));

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      }
    }
  }

  Widget _buildPixelLetter(String letter, {required bool isBrown}) {
    final textColor = isBrown ? MokaColors.brown : MokaColors.pink;
    final shadowColor = isBrown ? MokaColors.pink : MokaColors.brown;

    return Text(
      letter,
      style: GoogleFonts.pixelifySans(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        height: 0.85,
        color: textColor,
        shadows: [Shadow(color: shadowColor, offset: const Offset(3, 3))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MokaColors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Ornamen Background Estetik ala Piksel Y2K
          Positioned(
            top: 80,
            left: 40,
            child: Container(width: 8, height: 8, color: MokaColors.pink),
          ),
          Positioned(
            top: 120,
            right: 50,
            child: Container(
              width: 12,
              height: 12,
              color: MokaColors.brownSoft.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 50,
            child: Container(width: 10, height: 10, color: MokaColors.pinkSoft),
          ),

          // Konten Utama Splash Screen
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tulisan "WELCOME" Sesuai Permintaan
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: MokaColors.pinkSoft,
                  border: Border.all(color: MokaColors.pink, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'WELCOME TO MOKA',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: MokaColors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Logo moka.png dengan Animasi Denyut (Scale Transition)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: MokaColors.cream,
                    shape: BoxShape.circle,
                    border: Border.all(color: MokaColors.pink, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: MokaColors.brown,
                        offset: Offset(4, 4),
                        blurRadius: 0, // Efek hard shadow piksel
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/moka.png', // Pastikan path asset sudah sesuai
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_cafe,
                          size: 70,
                          color: MokaColors.pink,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Nama Brand M O K A (Pixel Font)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPixelLetter('M', isBrown: true),
                  const SizedBox(width: 8),
                  _buildPixelLetter('O', isBrown: false),
                  const SizedBox(width: 8),
                  _buildPixelLetter('K', isBrown: true),
                  const SizedBox(width: 8),
                  _buildPixelLetter('A', isBrown: false),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'POS TERMINAL & COFFEE SHOP',
                style: GoogleFonts.pixelifySans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                  color: MokaColors.brownSoft,
                ),
              ),
            ],
          ),

          // Animasi Loading Indikator Titik Piksel Bergerak di Bagian Bawah
          Positioned(
            bottom: 50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return _BouncingDot(delay: index * 200);
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  'Memuat Sistem...',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: MokaColors.brownSoft,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Pendukung untuk Animasi Titik Bouncing (Naik-Turun Bergantian)
class _BouncingDot extends StatefulWidget {
  final int delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _animController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.delay == 200 ? MokaColors.pink : MokaColors.brown,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}
