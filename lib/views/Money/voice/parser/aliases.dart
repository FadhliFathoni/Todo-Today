/// Kamus alias untuk wallet, kategori, type, dan kata-kata waktu.
///
/// Semua key & value HARUS lowercase. Matching dilakukan setelah teks
/// dinormalisasi (lihat `text_normalizer.dart`).
library;

/// Default fallback values sesuai spesifikasi fitur.
class FinanceDefaults {
  static const String wallet = 'bca1';
  static const String expenseCategory = 'jajan';
  static const String incomeCategory = 'general';
}

/// Alias built-in untuk wallet umum di Indonesia. Project bisa menambah
/// wallet dinamis dari Firestore lewat `WalletMatcher` (lihat constructor).
const Map<String, List<String>> defaultWalletAliases = {
  'BCA1': ['bca', 'bca satu', 'bca 1', 'b c a satu', 'b c a 1'],
  'BCA2': ['bca dua', 'bca 2', 'b c a dua'],
  'Mandiri': ['mandiri', 'bank mandiri'],
  'BNI': ['bni', 'b n i'],
  'BRI': ['bri', 'b r i'],
  'Cash': ['cash', 'tunai', 'cash money', 'uang cash'],
  'OVO': ['ovo'],
  'Gopay': ['gopay', 'go pay', 'go-pay'],
  'Dana': ['dana'],
  'Shopeepay': ['shopeepay', 'shopee pay'],
  'Tabungan': ['tabungan'],
  'Dana Darurat': ['dana darurat', 'darurat'],
  'Kebutuhan': ['kebutuhan', 'kebutuhan sehari-hari'],
  'Kendaraan': ['kendaraan', 'kendaraan umum'],
};

/// Alias built-in untuk kategori. Project bisa override / extend dari
/// koleksi `kategori` Firestore lewat `CategoryMatcher`.
const Map<String, List<String>> defaultCategoryAliases = {
  'jajan': ['jajan', 'snack', 'cemilan', 'kopi', 'minuman', 'makan ringan'],
  'makanan': ['makan', 'makanan', 'lunch', 'dinner', 'sarapan', 'breakfast'],
  'transport': [
    'transport',
    'transportasi',
    'gojek',
    'grab',
    'ojek',
    'taksi',
    'taxi',
    'bensin',
    'parkir',
    'tol',
  ],
  'belanja': ['belanja', 'shopping'],
  'belanja online': ['belanja online', 'online shop', 'shopee', 'tokopedia', 'lazada'],
  'tagihan': ['tagihan', 'listrik', 'air', 'pulsa', 'wifi', 'internet'],
  'hiburan': ['hiburan', 'nonton', 'bioskop', 'netflix', 'spotify', 'game'],
  'kesehatan': ['kesehatan', 'obat', 'dokter', 'rumah sakit', 'apotek'],
  'gaji': ['gaji', 'salary'],
  'bonus': ['bonus', 'thr', 'komisi'],
  'general': ['general', 'umum', 'lain', 'lainnya'],
};

/// Kata kunci untuk mendeteksi tipe transaksi.
const List<String> expenseKeywords = [
  'pengeluaran',
  'keluar',
  'beli',
  'belanja',
  'bayar',
  'jajan',
  'jajanin',
  'spend',
];

const List<String> incomeKeywords = [
  'pemasukan',
  'masuk',
  'gaji',
  'gajian',
  'bonus',
  'thr',
  'refund',
  'pengembalian',
  'dapat',
  'dapet',
  'terima',
  'transferan',
  'transfer masuk',
  'income',
];

/// Filler / noise yang aman dibuang sebelum parsing utama.
const List<String> fillerWords = [
  'dong',
  'dongs',
  'ya',
  'yah',
  'deh',
  'sih',
  'lah',
  'kayak',
  'kayaknya',
  'aja',
  'tuh',
  'nih',
  'kok',
  'tadi',
  'barusan',
  'eh',
  'em',
  'um',
  'mmm',
  'oke',
  'ok',
  'hmm',
];

/// Mapping angka spelled-out (Bahasa Indonesia) ke int.
const Map<String, int> spelledNumberWords = {
  'nol': 0,
  'kosong': 0,
  'satu': 1,
  'se': 1, // se- (setengah, seratus, seribu) ditangani khusus
  'dua': 2,
  'tiga': 3,
  'empat': 4,
  'lima': 5,
  'enam': 6,
  'tujuh': 7,
  'delapan': 8,
  'sembilan': 9,
  'sepuluh': 10,
  'sebelas': 11,
};

/// Bagian-bagian waktu hari → range jam default-nya (24h).
/// Dipakai bila user hanya bilang "pagi/siang/sore/malam" tanpa angka jam.
const Map<String, int> dayPartDefaultHour = {
  'subuh': 5,
  'pagi': 8,
  'siang': 13,
  'sore': 16,
  'petang': 17,
  'malam': 20,
  'tengah malam': 0,
  'dini hari': 3,
};
