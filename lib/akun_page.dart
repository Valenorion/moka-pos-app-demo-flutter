import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'moka_theme.dart';
import 'auth_page.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Hapus status login
    await prefs.remove('cartIds'); // Bersihkan keranjang kasir saat logout

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sistem POS',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: MokaColors.brown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pengaturan kasir dan laporan shift harian.',
            style: GoogleFonts.dmSans(color: MokaColors.brownSoft),
          ),
          const SizedBox(height: 24),

          // Kartu Profil Kasir
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MokaColors.pinkSoft,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: MokaColors.pink, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: MokaColors.brown,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: MokaColors.white, width: 2),
                  ),
                  child: Center(
                    child: Image.asset('assets/moka.png', width: 40),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KASIR AKTIF',
                        style: GoogleFonts.vt323(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MokaColors.brownSoft,
                        ),
                      ),
                      Text(
                        'Valen',
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MokaColors.brown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: MokaColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: MokaColors.pink),
                        ),
                        child: Text(
                          'ID: MKA-08403 • SHIFT PAGI',
                          style: GoogleFonts.vt323(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MokaColors.brown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Operasional',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MokaColors.brownSoft,
            ),
          ),
          const SizedBox(height: 12),

          _HoverableMenuTile(
            icon: Icons.point_of_sale,
            title: 'Rekap Laci Uang (End of Day)',
            onTap: () =>
                _showSystemMsg(context, 'Merekap total kas laci hari ini...'),
          ),
          _HoverableMenuTile(
            icon: Icons.history,
            title: 'Riwayat Shift & Absensi',
            onTap: () => _showSystemMsg(context, 'Membuka data absen kasir...'),
          ),
          _HoverableMenuTile(
            icon: Icons.print_outlined,
            title: 'Pengaturan Printer Thermal',
            onTap: () => _showSystemMsg(
              context,
              'Mencari printer bluetooth terdekat...',
            ),
          ),

          const Divider(height: 40, color: MokaColors.pinkSoft, thickness: 1.5),

          Text(
            'Sistem & Bantuan',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MokaColors.brownSoft,
            ),
          ),
          const SizedBox(height: 12),

          _HoverableMenuTile(
            icon: Icons.support_agent,
            title: 'Hubungi Supervisor',
            onTap: () =>
                _showSystemMsg(context, 'Memanggil Supervisor ke station...'),
          ),
          _HoverableMenuTile(
            icon: Icons.cloud_sync,
            title: 'Sinkronisasi Data Menu',
            onTap: () => _showSystemMsg(
              context,
              'Memperbarui katalog harga dari server...',
            ),
          ),

          const SizedBox(height: 16),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _logout(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.exit_to_app, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      'Tutup Shift (Logout)',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSystemMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: MokaColors.pink),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: GoogleFonts.dmSans())),
          ],
        ),
        backgroundColor: MokaColors.brown,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Widget Custom Interaktif untuk Tile Menu
class _HoverableMenuTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HoverableMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_HoverableMenuTile> createState() => _HoverableMenuTileState();
}

class _HoverableMenuTileState extends State<_HoverableMenuTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          transform: Matrix4.translationValues(_isHovered ? 5 : 0, 0, 0),
          decoration: BoxDecoration(
            color: _isHovered ? MokaColors.pinkSoft : MokaColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? MokaColors.pink : MokaColors.pinkSoft,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovered ? MokaColors.white : MokaColors.pinkSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: MokaColors.brown),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    color: MokaColors.brown,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: _isHovered ? MokaColors.brown : MokaColors.brownSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
