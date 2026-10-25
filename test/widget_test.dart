import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uts_a112415676/main.dart';

void main() {
  testWidgets('MokaApp load test', (WidgetTester tester) async {
    // Memuat root widget aplikasi MOKA
    await tester.pumpWidget(const MokaApp());

    // Menunggu hingga semua animasi awal atau rendering selesai
    await tester.pumpAndSettle();

    // Memastikan struktur utama aplikasi (MaterialApp dan halaman) berhasil terbuat
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
