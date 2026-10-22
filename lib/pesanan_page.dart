import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'moka_theme.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _history = prefs.getStringList('order_history') ?? [];
    });
  }

  String _formatRupiah(double number) {
    return 'Rp ${number.toInt().toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}';
  }

  // WIDGET STRUK DIPANGGIL SAAT KARTU DIKLIK
  void _showReceiptDialog(List<String> data) {
    String id = data[0];
    String date = data[1];
    double total = double.parse(data[2]);

    String method = data.length > 3 ? data[3] : 'QRIS';
    double cash = data.length > 4 ? double.parse(data[4]) : total;
    double changeAmt = data.length > 5 ? double.parse(data[5]) : 0;
    String items = data.length > 6
        ? data[6]
        : 'Item tidak tercatat (Sistem Lama)';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: MokaColors.brownSoft, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'MOKA KASIR',
                textAlign: TextAlign.center,
                style: GoogleFonts.vt323(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Jl. Shibuya Crossing No. 8',
                textAlign: TextAlign.center,
                style: GoogleFonts.vt323(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                '- - - - - - - - - - - - - - - - - - - - - - -',
                maxLines: 1,
                style: GoogleFonts.vt323(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                'ID Trx : $id',
                style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
              ),
              Text(
                'Tanggal: $date',
                style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
              ),
              Text(
                'Kasir  : VALEN',
                style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                '- - - - - - - - - - - - - - - - - - - - - - -',
                maxLines: 1,
                style: GoogleFonts.vt323(color: Colors.black54),
              ),
              const SizedBox(height: 12),

              Text(
                items.replaceAll(', ', '\n'),
                style: GoogleFonts.vt323(fontSize: 18, color: Colors.black),
              ),

              const SizedBox(height: 12),
              Text(
                '- - - - - - - - - - - - - - - - - - - - - - -',
                maxLines: 1,
                style: GoogleFonts.vt323(color: Colors.black54),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL',
                    style: GoogleFonts.vt323(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _formatRupiah(total),
                    style: GoogleFonts.vt323(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'METODE BAYAR',
                    style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    method,
                    style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TUNAI / KREDIT',
                    style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    _formatRupiah(cash),
                    style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KEMBALI',
                    style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    _formatRupiah(changeAmt),
                    style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                '- - - - - - - - - - - - - - - - - - - - - - -',
                maxLines: 1,
                style: GoogleFonts.vt323(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Text(
                'TERIMA KASIH',
                textAlign: TextAlign.center,
                style: GoogleFonts.vt323(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MokaColors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup Struk',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    color: MokaColors.pinkSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: MokaColors.brown,
      backgroundColor: MokaColors.pinkSoft,
      onRefresh: _loadHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Transaksi',
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: MokaColors.brown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seluruh pencatatan transaksi kasir hari ini. Ketuk untuk cetak ulang struk.',
              style: GoogleFonts.dmSans(color: MokaColors.brownSoft),
            ),
            const SizedBox(height: 24),

            if (_history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: MokaColors.pinkSoft,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada transaksi tersimpan.',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: MokaColors.brownSoft,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tarik layar ke bawah untuk memuat ulang.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: MokaColors.brownSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final data = _history[index].split('|');
                  if (data.length < 3) return const SizedBox();

                  String displayedTotal = _formatRupiah(double.parse(data[2]));

                  // Menggunakan Widget Interaktif Terpisah untuk Efek Hover & Animasi Halus
                  return _HoverableHistoryCard(
                    data: data,
                    displayedTotal: displayedTotal,
                    onTap: () => _showReceiptDialog(data),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET KARTU RIWAYAT DENGAN EFEK HOVER & ANIMASI INTERAKTIF
// ============================================================================
class _HoverableHistoryCard extends StatefulWidget {
  final List<String> data;
  final String displayedTotal;
  final VoidCallback onTap;

  const _HoverableHistoryCard({
    required this.data,
    required this.displayedTotal,
    required this.onTap,
  });

  @override
  State<_HoverableHistoryCard> createState() => _HoverableHistoryCardState();
}

class _HoverableHistoryCardState extends State<_HoverableHistoryCard> {
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
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Berubah warna saat di-hover agar terasa interaktif
            color: _isHovered ? MokaColors.pinkSoft : MokaColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? MokaColors.brown : MokaColors.pinkSoft,
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    const BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 6),
                      blurRadius: 10,
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 2),
                      blurRadius: 5,
                    ),
                  ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isHovered ? MokaColors.brown : MokaColors.pink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.print,
                  color: _isHovered ? MokaColors.pinkSoft : MokaColors.brown,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data[0],
                      style: GoogleFonts.vt323(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MokaColors.brown,
                      ),
                    ),
                    Text(
                      'Waktu: ${widget.data[1]}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: MokaColors.brownSoft,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getShortItemsSummary(widget.data),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: MokaColors.brown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.displayedTotal,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MokaColors.brown,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF5EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sukses',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF53745A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi pembantu untuk menampilkan ringkasan item di card riwayat
  String _getShortItemsSummary(List<String> data) {
    if (data.length > 6) {
      return data[6]; // Menampilkan nama item yang dibeli
    }
    return 'Ketuk untuk cetak struk';
  }
}
