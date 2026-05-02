import 'package:flutter_test/flutter_test.dart';
import 'package:todo_today/views/Money/voice/parser/amount_parser.dart';
import 'package:todo_today/views/Money/voice/parser/datetime_parser.dart';
import 'package:todo_today/views/Money/voice/parser/finance_voice_parser.dart';
import 'package:todo_today/views/Money/voice/parser/text_normalizer.dart';

void main() {
  group('normalizeText', () {
    test('lowercase + strip rp + ekspansi rb/jt/k', () {
      expect(normalizeText('Rp20.000'), '20000');
      expect(normalizeText('20rb'), '20 ribu');
      expect(normalizeText('5jt'), '5 juta');
      expect(normalizeText('20K'), '20 ribu');
    });

    test('buang filler', () {
      expect(normalizeText('jajan kopi 30 ribu dong ya'), 'jajan kopi 30 ribu');
    });
  });

  group('extractAmount', () {
    test('digit + unit', () {
      expect(extractAmount(normalizeText('20 ribu')).amount, 20000);
      expect(extractAmount(normalizeText('5 juta')).amount, 5000000);
      expect(extractAmount(normalizeText('1.5 juta')).amount, 1500000);
      expect(extractAmount(normalizeText('Rp20.000')).amount, 20000);
    });

    test('setengah / seperempat', () {
      expect(extractAmount(normalizeText('setengah juta')).amount, 500000);
      expect(extractAmount(normalizeText('seperempat juta')).amount, 250000);
    });

    test('spelled-out', () {
      expect(extractAmount(normalizeText('dua puluh ribu')).amount, 20000);
      expect(extractAmount(normalizeText('lima juta')).amount, 5000000);
    });

    test('angka kecil tanpa unit tidak dianggap nominal', () {
      // "tanggal 1" jangan dianggap 1 rupiah
      expect(extractAmount(normalizeText('tanggal 1')).found, false);
    });
  });

  group('extractDateTime', () {
    final now = DateTime(2026, 4, 21, 10, 0);
    test('jam 8 pagi', () {
      final r = extractDateTime(normalizeText('jam 8 pagi'), now: now);
      expect(r.dateTime.hour, 8);
      expect(r.timeExplicit, true);
    });
    test('jam 3 sore', () {
      final r = extractDateTime(normalizeText('jam 3 sore'), now: now);
      expect(r.dateTime.hour, 15);
    });
    test('tanggal 1', () {
      final r = extractDateTime(normalizeText('tanggal 1'), now: now);
      expect(r.dateTime.day, 1);
      expect(r.dateExplicit, true);
    });
    test('default = now', () {
      final r = extractDateTime('beli kopi', now: now);
      expect(r.dateExplicit, false);
      expect(r.timeExplicit, false);
    });
  });

  group('FinanceVoiceParser', () {
    final parser = FinanceVoiceParser(
      availableWallets: ['BCA1', 'BCA2', 'OVO', 'CASH'],
      availableCategories: ['Jajan', 'Transport', 'Makanan', 'Belanja', 'Belanja Online', 'Tagihan', 'Hiburan', 'Kesehatan', 'Gaji', 'Bonus'],
    );
    final now = DateTime(2026, 4, 21, 10, 0);

    test('contoh 1: pengeluaran indomaret 20 ribu jam 8 pagi', () {
      final r = parser.parse('pengeluaran indomaret 20 ribu jam 8 pagi', now: now);
      expect(r.type, 'expense');
      expect(r.amount, 20000);
      expect(r.dateTime.hour, 8);
      expect(r.title.contains('indomaret'), true);
      expect(r.wallet, 'BCA1'); // default
    });

    test('contoh 2: jajan kopi 30rb dari bca1 kategori minuman', () {
      final r = parser.parse('jajan kopi 30rb dari bca1 kategori minuman', now: now);
      expect(r.type, 'expense');
      expect(r.amount, 30000);
      expect(r.wallet, 'BCA1');
    });

    test('contoh 3: pemasukan gaji 5 juta tanggal 1', () {
      final r = parser.parse('pemasukan gaji 5 juta tanggal 1', now: now);
      expect(r.type, 'income');
      expect(r.amount, 5000000);
      expect(r.dateTime.day, 1);
    });

    test('contoh 4: tanpa wallet → default bca1', () {
      final r = parser.parse('beli bensin 50 ribu', now: now);
      expect(r.wallet, 'BCA1');
      expect(r.missingFields.contains('wallet'), true);
    });

    test('contoh 5: tanpa kategori expense → jajan', () {
      final r = parser.parse('beli sesuatu 10 ribu', now: now);
      expect(r.category, 'Jajan');
    });

    test('contoh 6: confidence rendah saat amount tidak ada', () {
      final r = parser.parse('beli kopi', now: now);
      expect(r.confidence < 0.7, true);
    });
  });
}
