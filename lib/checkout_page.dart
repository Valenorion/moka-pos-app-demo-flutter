import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menu_data.dart';

class CheckoutColors {
  static const mochaDark = Color(0xFF2D1813);
  static const mocha = Color(0xFF48291F);
  static const mochaMuted = Color(0xFF846F67);
  static const pink = Color(0xFFF4A5B8);
  static const pinkLight = Color(0xFFFFF0F4);
  static const pinkMid = Color(0xFFE88DA3);
  static const cream = Color(0xFFFAF7F5);
  static const white = Color(0xFFFFFFFF);
  static const line = Color(0xFFEADFDB);
  static const success = Color(0xFF53745A);
  static const error = Color(0xFFBE4F62);
  static const background = Color(0xFFF5F5F5);
}

String formatRupiah(double number) {
  return 'Rp ${number.toInt().toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}';
}

class CheckoutPage extends StatefulWidget {
  final List<Product> cart;
  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late List<Product> _localCart;
  String _selectedPayment = 'QRIS';
  late TextEditingController _cashCtrl;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _localCart = List.from(widget.cart);
    _cashCtrl = TextEditingController(text: total.toInt().toString());
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  double get subtotal => _localCart.fold(0, (sum, item) => sum + item.price);
  double get tax => subtotal * 0.1;
  double get total => subtotal + tax;

  Map<int, Map<String, dynamic>> get groupedCart {
    Map<int, Map<String, dynamic>> map = {};
    for (var p in _localCart) {
      if (map.containsKey(p.id)) {
        map[p.id]!['qty'] += 1;
      } else {
        map[p.id] = {'product': p, 'qty': 1};
      }
    }
    return map;
  }

  double get change {
    double cash = double.tryParse(_cashCtrl.text.replaceAll('.', '')) ?? 0;
    return (cash >= total) ? (cash - total) : 0;
  }

  bool get isInsufficient {
    if (_selectedPayment != 'CASH') return false;
    double cash = double.tryParse(_cashCtrl.text.replaceAll('.', '')) ?? 0;
    return cash < total;
  }

  void _syncCashAmount() {
    _cashCtrl.text = total.toInt().toString();
  }

  Future<void> _syncCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartIds = _localCart.map((p) => p.id.toString()).toList();
    await prefs.setStringList('cartIds', cartIds);
  }

  void _incrementQuantity(Product p) {
    setState(() {
      _localCart.add(p);
      _syncCashAmount();
    });
    _syncCartToPrefs();
  }

  void _decrementQuantity(int productId) {
    setState(() {
      int index = _localCart.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _localCart.removeAt(index);
        _syncCashAmount();
      }
    });
    _syncCartToPrefs();
  }

  void _removeItemCompletely(int productId) {
    setState(() {
      _localCart.removeWhere((p) => p.id == productId);
      _syncCashAmount();
    });
    _syncCartToPrefs();
  }

  void _setCashAmount(double amount) {
    setState(() {
      _cashCtrl.text = amount.toInt().toString();
      _isPaid = false;
    });
  }

  Future<void> _processAndSaveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('order_history') ?? [];

    final orderId =
        'MKA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final date =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    // Siapkan data struk sebelum cart dibersihkan
    final double finalTotal = total;
    final String finalMethod = _selectedPayment;
    final double finalCash = _selectedPayment == 'CASH'
        ? (double.tryParse(_cashCtrl.text.replaceAll('.', '')) ?? finalTotal)
        : finalTotal;
    final double finalChange = _selectedPayment == 'CASH' ? change : 0;

    // Gabungkan nama item untuk history
    String itemsSummary = groupedCart.values
        .map((item) {
          Product p = item['product'];
          int qty = item['qty'];
          return "${p.name} x$qty";
        })
        .join(", ");

    // FORMAT BARU: ID|Tanggal|Total|Metode|Tunai|Kembali|Item1 x1, Item2 x2
    final orderData =
        "$orderId|$date|${finalTotal.toInt()}|$finalMethod|${finalCash.toInt()}|${finalChange.toInt()}|$itemsSummary";

    history.insert(0, orderData);
    await prefs.setStringList('order_history', history);
    await prefs.remove('cartIds');

    // Tampilkan Struk
    if (mounted) {
      setState(() => _isPaid = true);
      _showReceiptDialog(
        orderId,
        date,
        finalTotal,
        finalMethod,
        finalCash,
        finalChange,
        itemsSummary,
      );
    }
  }

  void _processPayment() {
    if (_localCart.isEmpty) return;

    if (_selectedPayment == 'QRIS') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: CheckoutColors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan QRIS Pelanggan',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CheckoutColors.mochaDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${formatRupiah(total)}',
                  style: GoogleFonts.vt323(
                    fontSize: 24,
                    color: CheckoutColors.pinkMid,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CheckoutColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CheckoutColors.line, width: 2),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    size: 200,
                    color: CheckoutColors.mochaDark,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Menunggu verifikasi pembayaran...',
                  style: GoogleFonts.dmSans(color: CheckoutColors.mochaMuted),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CheckoutColors.mocha,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Tutup QRIS
                      _processAndSaveOrder();
                    },
                    child: Text(
                      'Konfirmasi Pembayaran Lunas',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: CheckoutColors.pinkLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      _processAndSaveOrder();
    }
  }

  // WIDGET STRUK KERTAS TERMAL
  void _showReceiptDialog(
    String id,
    String date,
    double finalTotal,
    String method,
    double cash,
    double changeAmt,
    String items,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: CheckoutColors.line, width: 1),
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

              // Rincian Item (dipecah dari koma menjadi baris baru)
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
                    formatRupiah(finalTotal),
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
                    formatRupiah(cash),
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
                    formatRupiah(changeAmt),
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
                  backgroundColor: CheckoutColors.mocha,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Tutup Struk
                  Navigator.pop(context); // Tutup Checkout kembali ke Dashboard
                },
                child: Text(
                  'Cetak & Selesai',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    color: CheckoutColors.pinkLight,
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
    return Scaffold(
      backgroundColor: CheckoutColors.background,
      appBar: AppBar(
        backgroundColor: CheckoutColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: CheckoutColors.mochaDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review & Terminal Kasir',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CheckoutColors.mochaDark,
          ),
        ),
      ),
      body: SafeArea(
        child: _localCart.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 80,
                      color: CheckoutColors.mochaMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada menu yang dicatat.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: CheckoutColors.mochaMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CheckoutColors.mocha,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Kembali ke Katalog',
                        style: GoogleFonts.dmSans(
                          color: CheckoutColors.pinkLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. KARTU INFORMASI SHIFT
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CheckoutColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: CheckoutColors.pinkLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.tablet_mac,
                              color: CheckoutColors.mocha,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pencatatan Pesanan Kasir',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: CheckoutColors.mochaMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Shift Kasir: Pagi (Moka Shibuya)',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: CheckoutColors.mochaDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. REVIEW & EDIT PESANAN (TABLET KASIR STYLE)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CheckoutColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar Pesanan Pelanggan',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CheckoutColors.mochaDark,
                                ),
                              ),
                              Text(
                                '${_localCart.length} Item',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: CheckoutColors.mochaMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...groupedCart.values.map((item) {
                            final Product p = item['product'];
                            final int qty = item['qty'];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CheckoutColors.cream,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: CheckoutColors.line),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      p.image,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: CheckoutColors.mochaDark,
                                          ),
                                        ),
                                        Text(
                                          formatRupiah(p.price),
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: CheckoutColors.mochaMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: CheckoutColors.mocha,
                                        ),
                                        onPressed: () =>
                                            _decrementQuantity(p.id),
                                        iconSize: 22,
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Kurangi 1',
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '$qty',
                                          style: GoogleFonts.vt323(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: CheckoutColors.mochaDark,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: CheckoutColors.mocha,
                                        ),
                                        onPressed: () => _incrementQuantity(p),
                                        iconSize: 22,
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Tambah 1',
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: CheckoutColors.error,
                                        ),
                                        onPressed: () =>
                                            _removeItemCompletely(p.id),
                                        iconSize: 22,
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Hapus Menu',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. METODE PEMBAYARAN
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CheckoutColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metode Pembayaran',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CheckoutColors.mochaDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          HoverablePaymentCard(
                            onTap: () => setState(() {
                              _selectedPayment = 'QRIS';
                              _isPaid = false;
                            }),
                            isSelected: _selectedPayment == 'QRIS',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.qr_code_2_rounded,
                                  color: CheckoutColors.mochaDark,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'QRIS (Gopay, ShopeePay, Dana)',
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.bold,
                                      color: CheckoutColors.mochaDark,
                                    ),
                                  ),
                                ),
                                if (_selectedPayment == 'QRIS')
                                  const Icon(
                                    Icons.check_circle,
                                    color: CheckoutColors.pinkMid,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          HoverablePaymentCard(
                            onTap: () => setState(() {
                              _selectedPayment = 'CASH';
                              _isPaid = false;
                            }),
                            isSelected: _selectedPayment == 'CASH',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.money,
                                      color: CheckoutColors.mochaDark,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Uang Tunai (Cash)',
                                        style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.bold,
                                          color: CheckoutColors.mochaDark,
                                        ),
                                      ),
                                    ),
                                    if (_selectedPayment == 'CASH')
                                      const Icon(
                                        Icons.check_circle,
                                        color: CheckoutColors.pinkMid,
                                      ),
                                  ],
                                ),
                                if (_selectedPayment == 'CASH') ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(),
                                  ),
                                  Text(
                                    'Nominal uang diterima:',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      color: CheckoutColors.mochaMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CheckoutColors.white,
                                      border: Border.all(
                                        color: isInsufficient
                                            ? CheckoutColors.error
                                            : CheckoutColors.line,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Rp',
                                          style: GoogleFonts.vt323(
                                            fontSize: 22,
                                            color: CheckoutColors.mochaDark,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: _cashCtrl,
                                            keyboardType: TextInputType.number,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: CheckoutColors.mochaDark,
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: '0',
                                              isDense: true,
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildCashPresetBtn(total, 'Uang Pas'),
                                      const SizedBox(width: 8),
                                      _buildCashPresetBtn(100000, 'Rp 100rb'),
                                      const SizedBox(width: 8),
                                      _buildCashPresetBtn(200000, 'Rp 200rb'),
                                    ],
                                  ),
                                  if (change > 0 && !isInsufficient)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Kembalian Kasir:',
                                            style: GoogleFonts.dmSans(
                                              color: CheckoutColors.mochaMuted,
                                            ),
                                          ),
                                          Text(
                                            formatRupiah(change),
                                            style: GoogleFonts.dmSans(
                                              fontWeight: FontWeight.bold,
                                              color: CheckoutColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (isInsufficient)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        'Uang tunai kurang ${formatRupiah(total - (double.tryParse(_cashCtrl.text) ?? 0))}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: CheckoutColors.error,
                                        ),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. RINCIAN PEMBAYARAN
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CheckoutColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rincian Transaksi',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CheckoutColors.mochaDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal (${_localCart.length} item)',
                                style: GoogleFonts.dmSans(
                                  color: CheckoutColors.mochaMuted,
                                ),
                              ),
                              Text(
                                formatRupiah(subtotal),
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  color: CheckoutColors.mochaDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PB1 (10%)',
                                style: GoogleFonts.dmSans(
                                  color: CheckoutColors.mochaMuted,
                                ),
                              ),
                              Text(
                                formatRupiah(tax),
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  color: CheckoutColors.mochaDark,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Keseluruhan',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CheckoutColors.mochaDark,
                                ),
                              ),
                              Text(
                                formatRupiah(total),
                                style: GoogleFonts.vt323(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: CheckoutColors.pinkMid,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _localCart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CheckoutColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: CheckoutColors.mochaMuted,
                            ),
                          ),
                          Text(
                            formatRupiah(total),
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CheckoutColors.mochaDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: (isInsufficient || _isPaid) ? 0.5 : 1.0,
                      child: ElevatedButton(
                        onPressed: (isInsufficient || _isPaid)
                            ? null
                            : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CheckoutColors.mocha,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isPaid ? 'Sudah Dibayar' : 'Proses Bayar',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CheckoutColors.pinkLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCashPresetBtn(double amount, String label) {
    bool isSelected = (_cashCtrl.text == amount.toInt().toString());
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _setCashAmount(amount),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? CheckoutColors.pink : CheckoutColors.white,
              border: Border.all(
                color: isSelected ? CheckoutColors.pink : CheckoutColors.line,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? CheckoutColors.mochaDark
                      : CheckoutColors.mochaMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HoverablePaymentCard extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  const HoverablePaymentCard({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<HoverablePaymentCard> createState() => _HoverablePaymentCardState();
}

class _HoverablePaymentCardState extends State<HoverablePaymentCard> {
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
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? CheckoutColors.pinkLight
                  : CheckoutColors.white,
              border: Border.all(
                color: widget.isSelected
                    ? CheckoutColors.pink
                    : (_isHovered ? CheckoutColors.pink : CheckoutColors.line),
                width: widget.isSelected || _isHovered ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: CheckoutColors.pinkLight.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
