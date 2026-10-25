import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'moka_theme.dart';
import 'checkout_page.dart';
import 'auth_page.dart';

import 'menu_page.dart';
import 'pesanan_page.dart';
import 'akun_page.dart';

import 'menu_data.dart';

String formatRupiah(double number) {
  String result = number.toInt().toString().replaceAll(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    '.',
  );
  return 'Rp $result';
}

// ============================================================================
// WIDGET PROMO BANNER (POV KASIR)
// ============================================================================
class PromoBannerSlider extends StatefulWidget {
  const PromoBannerSlider({super.key});

  @override
  State<PromoBannerSlider> createState() => _PromoBannerSliderState();
}

class _PromoBannerSliderState extends State<PromoBannerSlider> {
  final PageController _pageController = PageController(initialPage: 999);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _banners = [
    {
      'tag': 'SHIFT PAGI',
      'title': 'Siap Melayani\nPelanggan!',
      'action': 'Mulai Order →',
      'bg': '0xFFFFF0F4',
    },
    {
      'tag': 'INFO KASIR',
      'title': 'Pastikan Uang\nKembalian Pas',
      'action': 'Cek Laci Kasir →',
      'bg': '0xFFF4F0FF',
    },
    {
      'tag': 'TARGET HARIAN',
      'title': 'Capai 100\nTransaksi!',
      'action': 'Lihat Laporan →',
      'bg': '0xFFF0FFF5',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBannerContent(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Color(int.parse(data['bg']!)),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MokaColors.pinkSoft, width: 2),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: MokaColors.pink,
                      boxShadow: [
                        BoxShadow(
                          color: MokaColors.brown,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      data['tag']!,
                      style: GoogleFonts.vt323(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: MokaColors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['title']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      letterSpacing: -1.0,
                      color: MokaColors.brown,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.only(bottom: 2),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: MokaColors.brown, width: 1.5),
                      ),
                    ),
                    child: Text(
                      data['action']!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: MokaColors.brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 15,
            top: 15,
            child: Container(
              width: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFE8C8C8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MokaColors.brown, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.point_of_sale,
                  color: MokaColors.brown,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            onPageChanged: (int index) {
              setState(() => _currentPage = index % _banners.length);
            },
            itemBuilder: (context, index) {
              final bannerData = _banners[index % _banners.length];
              return _buildBannerContent(bannerData);
            },
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? MokaColors.pink
                        : MokaColors.brownSoft.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET CATEGORY BUTTON
// ============================================================================
class CategoryButtonWidget extends StatefulWidget {
  final String title;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButtonWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CategoryButtonWidget> createState() => _CategoryButtonWidgetState();
}

class _CategoryButtonWidgetState extends State<CategoryButtonWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? MokaColors.pink
                      : (_isHovered ? MokaColors.pinkSoft : MokaColors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isSelected
                        ? MokaColors.brown
                        : MokaColors.pinkSoft,
                    width: 1.5,
                  ),
                  boxShadow: widget.isSelected || _isHovered
                      ? [
                          const BoxShadow(
                            color: MokaColors.brown,
                            offset: Offset(3, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(child: widget.icon),
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: MokaColors.brown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET NAVBAR ITEM & CART
// ============================================================================
class HoverableNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const HoverableNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<HoverableNavItem> createState() => _HoverableNavItemState();
}

class _HoverableNavItemState extends State<HoverableNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isActive || _isHovered
                    ? MokaColors.brown
                    : Colors.grey.shade400,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: widget.isActive
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: widget.isActive || _isHovered
                      ? MokaColors.brown
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverableCart extends StatefulWidget {
  final int itemCount;
  final double totalPrice;
  final VoidCallback onTap;
  const HoverableCart({
    super.key,
    required this.itemCount,
    required this.totalPrice,
    required this.onTap,
  });

  @override
  State<HoverableCart> createState() => _HoverableCartState();
}

class _HoverableCartState extends State<HoverableCart> {
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
          transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF381C15) : MokaColors.brown,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered
                ? [
                    const BoxShadow(
                      color: Colors.black38,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: MokaColors.pink,
                child: const Icon(
                  Icons.point_of_sale,
                  size: 20,
                  color: MokaColors.brown,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL PENJUALAN',
                    style: GoogleFonts.vt323(
                      fontSize: 10,
                      color: MokaColors.pinkSoft,
                    ),
                  ),
                  Text(
                    '${widget.itemCount} item${widget.itemCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: MokaColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                formatRupiah(widget.totalPrice),
                style: const TextStyle(
                  color: MokaColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward, color: MokaColors.pink),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET PRODUCT CARD (POV KASIR)
// ============================================================================
class ProductCardItem extends StatefulWidget {
  final Product product;
  final VoidCallback onImageOrTitleTap;
  final VoidCallback onAddTap;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.onImageOrTitleTap,
    required this.onAddTap,
  });

  @override
  State<ProductCardItem> createState() => _ProductCardItemState();
}

class _ProductCardItemState extends State<ProductCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: widget.onAddTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: MokaColors.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: _isHovered
                        ? Border.all(color: MokaColors.pink, width: 2.5)
                        : Border.all(color: Colors.transparent, width: 2.5),
                    boxShadow: _isHovered
                        ? [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ]
                        : [],
                    image: DecorationImage(
                      image: AssetImage(widget.product.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(8),
                  child: widget.product.tag.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          color: MokaColors.white,
                          child: Text(
                            widget.product.tag,
                            style: GoogleFonts.vt323(
                              fontSize: 10,
                              color: MokaColors.brown,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: widget.onImageOrTitleTap,
              child: Text(
                widget.product.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: _isHovered ? MokaColors.pink : MokaColors.brown,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatRupiah(widget.product.price),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: MokaColors.brownSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HALAMAN UTAMA DASHBOARD
// ============================================================================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  List<Product> cart = [];
  String _selectedCategory = 'Popular';

  @override
  void initState() {
    super.initState();
    _loadCart();

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

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    await _loadCart();
    setState(() {});
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartIds = prefs.getStringList('cartIds') ?? [];
    List<Product> loadedCart = [];
    for (String idStr in savedCartIds) {
      final id = int.tryParse(idStr);
      try {
        final p = products.firstWhere((prod) => prod.id == id);
        loadedCart.add(p);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    setState(() => cart = loadedCart);
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartIds = cart.map((p) => p.id.toString()).toList();
    await prefs.setStringList('cartIds', cartIds);
  }

  void _addToCart(Product p) {
    setState(() => cart.add(p));
    _saveCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${p.name} ditambahkan ke total penjualan!',
          style: GoogleFonts.dmSans(),
        ),
        backgroundColor: MokaColors.brown,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  double get totalPrice => cart.fold(0, (sum, item) => sum + item.price);

  void _navigateToCheckout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutPage(cart: cart)),
    );
    _loadCart();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
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

  void _showInfoDialog(
    String title,
    String message,
    IconData icon, {
    String? url,
    String? btnText,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: MokaColors.pink),
            const SizedBox(width: 10),
            Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          if (url != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MokaColors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Gagal membuka tautan.')),
                  );
                }
              },
              child: Text(
                btnText ?? 'Buka',
                style: const TextStyle(
                  color: MokaColors.pinkSoft,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showUpdatePasswordDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('user') ?? 'Valen';

    final userCtrl = TextEditingController(text: currentUser);
    final passCtrl = TextEditingController();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset, color: MokaColors.pink),
            const SizedBox(width: 10),
            Text(
              'Update Account',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: 'Username Baru'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MokaColors.brown),
            onPressed: () async {
              if (userCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username dan Password tidak boleh kosong!'),
                  ),
                );
                return;
              }
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              await prefs.setString('user', userCtrl.text);
              await prefs.setString('pass', passCtrl.text);

              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Sukses! Silakan gunakan kredensial baru.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Simpan',
              style: TextStyle(color: MokaColors.pinkSoft),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    List<Product> filteredProducts = _selectedCategory == 'Popular'
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();

    return RefreshIndicator(
      color: MokaColors.pink,
      backgroundColor: MokaColors.brown,
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MokaColors.pinkSoft,
                        border: Border.all(color: MokaColors.pink),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pin_drop,
                        size: 16,
                        color: MokaColors.brown,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ORDER FROM',
                          style: GoogleFonts.vt323(
                            fontSize: 10,
                            color: MokaColors.brownSoft,
                          ),
                        ),
                        const Text(
                          'Moka Shibuya',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  offset: const Offset(0, 50),
                  icon: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: MokaColors.brown,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/moka.png'), // DIHAPUS WARNANYA
                  ),
                  onSelected: (val) async {
                    if (val == 'call') {
                      _showInfoDialog(
                        'Call Center / WA',
                        'Layanan Pelanggan kami sedia membantu Anda:\n📞 0858-6981-8403\n(Aktif 24 Jam)',
                        Icons.headset_mic,
                        url: 'https://wa.me/6285869818403?text=Halo%20Admin%20MOKA,%20saya%20butuh%20bantuan.',
                        btnText: 'Chat WhatsApp',
                      );
                    } else if (val == 'sms') {
                      _showInfoDialog(
                        'SMS Center',
                        'Kirim kritik & saran via SMS ke:\n📱 0858-6981-8403',
                        Icons.sms,
                        url: 'sms:+6285869818403',
                        btnText: 'Kirim SMS',
                      );
                    } else if (val == 'maps') {
                      _showInfoDialog(
                        'Lokasi / Maps',
                        'Moka Shibuya\nJl. Shibuya Crossing No. 8, Lt. 1\nBuka: 08:00 - 22:00',
                        Icons.map,
                        url: 'https://maps.google.com/?q=Dian+Nuswantoro',
                        btnText: 'Buka Maps',
                      );
                    } else if (val == 'update') {
                      _showUpdatePasswordDialog();
                    } else if (val == 'logout') {
                      final navigator = Navigator.of(context);
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setBool('isLoggedIn', false);
                      await prefs.remove('cartIds');

                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthPage()),
                        (route) => false,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'call',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.headset_mic,
                            color: MokaColors.brown,
                          ),
                          const SizedBox(width: 12),
                          Text('Call Center', style: GoogleFonts.dmSans()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'sms',
                      child: Row(
                        children: [
                          const Icon(Icons.sms, color: MokaColors.brown),
                          const SizedBox(width: 12),
                          Text('SMS Center', style: GoogleFonts.dmSans()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'maps',
                      child: Row(
                        children: [
                          const Icon(Icons.map, color: MokaColors.brown),
                          const SizedBox(width: 12),
                          Text('Lokasi/Maps', style: GoogleFonts.dmSans()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'update',
                      child: Row(
                        children: [
                          const Icon(Icons.lock_reset, color: MokaColors.brown),
                          const SizedBox(width: 12),
                          Text(
                            'Update User & Password',
                            style: GoogleFonts.dmSans(),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(
                            'Logout',
                            style: GoogleFonts.dmSans(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: Color(0xFFBC7081),
                ),
                const SizedBox(width: 8),
                Text(
                  'KASIR AKTIF: VALEN',
                  style: GoogleFonts.vt323(
                    fontSize: 12,
                    color: const Color(0xFFBC7081),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Sweet day,\none sip away.',
              style: GoogleFonts.dmSans(
                fontSize: 42,
                height: 1.0,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.5,
                color: MokaColors.brown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih menu pesanan pelanggan.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: MokaColors.brownSoft,
              ),
            ),
            const SizedBox(height: 24),
            const PromoBannerSlider(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Kategori Menu',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: Text(
                      'See all',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFBC7081),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryButtonWidget(
                  title: 'Popular',
                  icon: const Icon(Icons.star, color: MokaColors.brown),
                  isSelected: _selectedCategory == 'Popular',
                  onTap: () => setState(() => _selectedCategory = 'Popular'),
                ),
                CategoryButtonWidget(
                  title: 'Signature',
                  icon: Image.asset(
                    'assets/moka.png', // DIHAPUS WARNANYA
                    width: 24,
                    height: 24,
                  ),
                  isSelected: _selectedCategory == 'Signature',
                  onTap: () => setState(() => _selectedCategory = 'Signature'),
                ),
                CategoryButtonWidget(
                  title: 'Coffee',
                  icon: const Icon(Icons.coffee, color: MokaColors.brown),
                  isSelected: _selectedCategory == 'Coffee',
                  onTap: () => setState(() => _selectedCategory = 'Coffee'),
                ),
                CategoryButtonWidget(
                  title: 'Non-coffee',
                  icon: const Icon(Icons.local_drink, color: MokaColors.brown),
                  isSelected: _selectedCategory == 'Non-coffee',
                  onTap: () => setState(() => _selectedCategory = 'Non-coffee'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _selectedCategory == 'Popular'
                      ? 'Paling Laris'
                      : 'Menu $_selectedCategory',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredProducts.length} minuman',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: MokaColors.brownSoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            filteredProducts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'Belum ada menu di kategori ini.',
                        style: TextStyle(color: MokaColors.brownSoft),
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCardItem(
                            product: filteredProducts[index],
                            onImageOrTitleTap: () =>
                                _showDescription(filteredProducts[index]),
                            onAddTap: () => _addToCart(filteredProducts[index]),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MokaColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Stack(
              children: [
                IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildHomeTab(),
                    MenuPage(products: products, onAddToCart: _addToCart),
                    const SizedBox(),
                    const PesananPage(),
                    const AkunPage(),
                  ],
                ),

                if (_showScrollToTop && _currentIndex == 0)
                  Positioned(
                    right: 20,
                    bottom: cart.isNotEmpty
                        ? 200
                        : 110, // DISESUAIKAN AGAR TIDAK NABRAK
                    child: FloatingActionButton.small(
                      onPressed: _scrollToTop,
                      backgroundColor: MokaColors.brown,
                      elevation: 4,
                      child: const Icon(
                        Icons.arrow_upward,
                        color: MokaColors.pink,
                      ),
                    ),
                  ),

                if (cart.isNotEmpty &&
                    (_currentIndex == 0 || _currentIndex == 1))
                  Positioned(
                    bottom: 115, // DITAIKKAN AGAR TIDAK NABRAK NAVBAR BAWAH
                    left: 20,
                    right: 20,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: HoverableCart(
                          itemCount: cart.length,
                          totalPrice: totalPrice,
                          onTap: _navigateToCheckout,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: MokaColors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: MokaColors.pinkSoft,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          HoverableNavItem(
                            icon: Icons.home_filled,
                            label: 'Home',
                            isActive: _currentIndex == 0,
                            onTap: () => setState(() => _currentIndex = 0),
                          ),
                          HoverableNavItem(
                            icon: Icons.menu_book_outlined,
                            label: 'Menu',
                            isActive: _currentIndex == 1,
                            onTap: () => setState(() => _currentIndex = 1),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    const SnackBar(
                                      content: Text('Menu Kasir Pintar MOKA!'),
                                    ),
                                  ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: MokaColors.brown,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      'assets/moka.png', // DIHAPUS WARNANYA
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'MOKA',
                                    style: GoogleFonts.vt323(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: MokaColors.brown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          HoverableNavItem(
                            icon: Icons.receipt_long_outlined,
                            label: 'Pesanan',
                            isActive: _currentIndex == 3,
                            onTap: () => setState(() => _currentIndex = 3),
                          ),
                          HoverableNavItem(
                            icon: Icons.person_outline,
                            label: 'Akun',
                            isActive: _currentIndex == 4,
                            onTap: () => setState(() => _currentIndex = 4),
                          ),
                        ],
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
}
