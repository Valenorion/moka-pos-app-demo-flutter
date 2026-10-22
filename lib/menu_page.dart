import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'moka_theme.dart';
import 'dashboard_page.dart';
import 'menu_data.dart';

class MenuPage extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;

  const MenuPage({
    super.key,
    required this.products,
    required this.onAddToCart,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 250 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 250 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  // FUNGSI REFRESH KATA KUNCI UTAMA
  Future<void> _handleRefresh() async {
    // Simulasi jeda jaringan/sinkronisasi katalog POS (misal: 1 detik)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        // Reset kategori ke 'All' atau perbarui status state jika diperlukan
        _selectedCategory = 'All';
      });

      // Tampilkan SnackBar kecil tanda refresh berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Katalog POS berhasil diperbarui!',
            style: GoogleFonts.dmSans(color: MokaColors.white),
          ),
          backgroundColor: MokaColors.brown,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDescription(Product p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: MokaColors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    p.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  p.name,
                  style: GoogleFonts.vt323(
                    fontSize: 28,
                    color: MokaColors.brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  p.detail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MokaColors.brownSoft,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  formatRupiah(p.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: MokaColors.brown,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MokaColors.pink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: MokaColors.brown,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.vt323(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MokaColors.brown,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Product> displayedProducts = _selectedCategory == 'All'
        ? widget.products
        : widget.products
              .where((p) => p.category == _selectedCategory)
              .toList();

    return Stack(
      children: [
        // MEMBUNGKUS DENGAN REFRESH INDICATOR UNTUK FITUR TARIK KE BAWAH (PULL-TO-REFRESH)
        RefreshIndicator(
          color: MokaColors.white,
          backgroundColor: MokaColors.brown,
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(), // Wajib agar bisa ditarik meskipun konten belum penuh
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Banner Interaktif (KASIR POV)
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color: MokaColors.white,
                              child: Text(
                                'KATALOG POS',
                                style: GoogleFonts.vt323(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: MokaColors.brown,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Terminal\nMenu Utama',
                              style: GoogleFonts.vt323(
                                fontSize: 36,
                                height: 1.0,
                                fontWeight: FontWeight.bold,
                                color: MokaColors.brown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pilih pesanan pelanggan dengan cepat, akurat, dan langsung terekap.',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: MokaColors.brownSoft,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.point_of_sale_sharp,
                        size: 54,
                        color: MokaColors.brown,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Baris Filter Kategori Menu
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: ['All', 'Signature', 'Coffee', 'Non-coffee'].map((
                      cat,
                    ) {
                      bool isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => setState(() => _selectedCategory = cat),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? MokaColors.brown
                                  : MokaColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? MokaColors.brown
                                    : MokaColors.pinkSoft,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(0, 3),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? MokaColors.pinkSoft
                                    : MokaColors.brown,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Grid Daftar Produk
                displayedProducts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            'Belum ada menu di kategori ini.',
                            style: GoogleFonts.dmSans(
                              color: MokaColors.brownSoft,
                            ),
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 2;
                          double aspectRatio = 0.75;
                          if (constraints.maxWidth > 700) {
                            crossAxisCount = 4;
                            aspectRatio = 0.72;
                          } else if (constraints.maxWidth > 480) {
                            crossAxisCount = 3;
                            aspectRatio = 0.75;
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: aspectRatio,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: displayedProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCardItem(
                                product: displayedProducts[index],
                                onImageOrTitleTap: () =>
                                    _showDescription(displayedProducts[index]),
                                onAddTap: () => widget.onAddToCart(
                                  displayedProducts[index],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ),

        // 4. Tombol Scroll ke Atas
        if (_showScrollToTop)
          Positioned(
            right: 20,
            bottom: 140,
            child: FloatingActionButton.small(
              heroTag: 'menu_fab',
              onPressed: _scrollToTop,
              backgroundColor: MokaColors.brown,
              elevation: 4,
              child: const Icon(Icons.arrow_upward, color: MokaColors.pink),
            ),
          ),
      ],
    );
  }
}
