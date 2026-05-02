import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
import 'package:todo_today/views/Money/ListCategoryPage.dart';
import 'package:todo_today/views/Money/ListWalletPage.dart';
import 'package:todo_today/views/Money/voice/models/parsed_finance.dart';
import 'package:todo_today/views/Money/voice/parser/finance_voice_parser.dart';
import 'package:todo_today/views/Money/voice/service/voice_input_service.dart';

enum _VoiceState { idle, listening, confirming }

class VoiceInputPage extends StatefulWidget {
  const VoiceInputPage({super.key, required this.user});

  final String user;

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  final VoiceInputService _voice = VoiceInputService();
  _VoiceState _state = _VoiceState.idle;
  String _liveText = '';
  String? _error;

  ParsedFinance? _parsed;

  late final TextEditingController _titleC;
  late final TextEditingController _amountC;
  late DateTime _dateTime;
  late String _type;

  /// Sinkron dengan id dokumen Firestore `wallet` (sama seperti dialog FinancialPage).
  String? _selectedWalletId;

  /// Nama kategori — nilai dropdown, sama seperti `selectedKategori` di FinancialPage.
  String? _selectedKategori;

  late final CollectionReference<Map<String, dynamic>> _walletRef;
  late final CollectionReference<Map<String, dynamic>> _kategoriRef;

  List<String> _wallets = [];
  List<String> _walletDocIds = [];
  List<String> _categories = [];

  /// Cache key per akun biar default dompet/kategori/tipe tetap antar kunjungan.
  String get _prefsKeyWallet => 'voice_default_wallet_doc_${widget.user}';
  String get _prefsKeyKategori => 'voice_default_kategori_${widget.user}';
  String get _prefsKeyType => 'voice_default_tx_type_${widget.user}';

  Future<void> _persistVoiceDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_selectedWalletId != null) {
        await prefs.setString(_prefsKeyWallet, _selectedWalletId!);
      }
      if (_selectedKategori != null) {
        await prefs.setString(_prefsKeyKategori, _selectedKategori!);
      }
      await prefs.setString(_prefsKeyType, _type);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController();
    _amountC = TextEditingController();
    _dateTime = DateTime.now();
    _type = 'expense';
    final fs =
        FirebaseFirestore.instance.collection('finance').doc(widget.user);
    _walletRef = fs.collection('wallet');
    _kategoriRef = fs.collection('kategori');
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final wSnap = await _walletRef.get();
    final cSnap = await _kategoriRef.get();
    final prefs = await SharedPreferences.getInstance();
    final cachedWalletId = prefs.getString(_prefsKeyWallet);
    final cachedKategori = prefs.getString(_prefsKeyKategori);
    final cachedType = prefs.getString(_prefsKeyType);

    if (!mounted) return;
    setState(() {
      _walletDocIds = wSnap.docs.map((d) => d.id).toList();
      _wallets =
          wSnap.docs.map((d) => (d.data()['name'] ?? d.id).toString()).toList();
      _categories =
          cSnap.docs.map((d) => (d.data()['name'] ?? '').toString()).toList();

      if (cachedWalletId != null && _walletDocIds.contains(cachedWalletId)) {
        _selectedWalletId = cachedWalletId;
      } else if (_walletDocIds.isNotEmpty) {
        _selectedWalletId = _walletDocIds.first;
      }

      if (cachedKategori != null &&
          _categories.any((c) => c == cachedKategori)) {
        _selectedKategori = cachedKategori;
      } else if (_categories.isNotEmpty) {
        _selectedKategori = _categories.first;
      }

      if (cachedType == 'income' || cachedType == 'expense') {
        _type = cachedType!;
      }
    });

    // permission_handler tidak mendaftarkan microphone di macOS/Windows/Linux
    // (MissingPluginException). Di desktop, izin biasanya diminta saat listen()
    // oleh engine speech_to_text / OS.
    await _requestMicPermissionIfMobile();
    if (!mounted) return;
    await _voice.init(
      onStatus: (_) {},
      onError: (e) {
        // Hindari race: callback plugin bisa fire saat route sudah turun / dispose berjalan.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _error = e;
            _state = _VoiceState.idle;
          });
        });
      },
    );
  }

  Future<void> _requestMicPermissionIfMobile() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      await Permission.microphone.request();
    } catch (_) {
      // Build tanpa permission_handler native, dll.
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _amountC.dispose();
    _voice.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (_state == _VoiceState.listening) {
      await _stopListening();
      return;
    }
    await _startListening();
  }

  Future<void> _startListening() async {
    if (!_voice.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Suara tidak tersedia di perangkat ini. Coba platform lain atau build ulang aplikasi.',
          ),
        ),
      );
      return;
    }
    setState(() {
      _liveText = '';
      _error = null;
      _state = _VoiceState.listening;
    });
    await _voice.start(
      onResult: (text, _) {
        if (!mounted) return;
        setState(() => _liveText = text);
      },
    );
    if (!mounted) return;
  }

  Future<void> _stopListening() async {
    await _voice.stop();
    if (!mounted) return;
    if (_liveText.trim().isNotEmpty) {
      _onFinalText(_liveText);
    } else {
      setState(() => _state = _VoiceState.idle);
    }
  }

  void _onFinalText(String text) {
    if (!mounted) return;
    final parser = FinanceVoiceParser(
      availableWallets: _wallets,
      availableCategories: _categories,
    );
    final parsed = parser.parse(text);

    setState(() {
      _parsed = parsed;
      _type = parsed.type;
      _titleC.text = parsed.title;
      _amountC.text = formatToRupiah(parsed.amount);
      _dateTime = parsed.dateTime;
      _state = _VoiceState.confirming;
      _applyParsedWalletAndCategory(parsed);
    });
    _persistVoiceDefaults();
  }

  /// Cocokkan string dari parser hanya jika wallet/kategori **memang diucapkan** (bukan isi
  /// [FinanceDefaults] bawaan parser). Kalau tidak di suara, biarkan pilihan cache/idle.
  void _applyParsedWalletAndCategory(ParsedFinance parsed) {
    final speechMentionedWallet = !parsed.missingFields.contains('wallet');
    final speechMentionedCategory = !parsed.missingFields.contains('category');

    if (speechMentionedWallet) {
      final pw = parsed.wallet.trim();
      if (pw.isNotEmpty) {
        var wi = _wallets.indexWhere(
          (w) => w.toLowerCase() == pw.toLowerCase(),
        );
        if (wi < 0) {
          wi = _walletDocIds.indexWhere(
            (id) => id.toLowerCase() == pw.toLowerCase(),
          );
        }
        if (wi >= 0) {
          _selectedWalletId = _walletDocIds[wi];
        }
      }
    }

    if (speechMentionedCategory) {
      final pc = parsed.category.trim();
      if (pc.isNotEmpty) {
        final ci = _categories.indexWhere(
          (c) => c.toLowerCase() == pc.toLowerCase(),
        );
        if (ci >= 0) {
          _selectedKategori = _categories[ci];
        }
      }
    }
  }

  Future<void> _save() async {
    final amount = convertRupiahToInt(_amountC.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal belum diisi')),
      );
      return;
    }
    final walletSnap = await _walletRef.get();
    final walletIds = walletSnap.docs.map((d) => d.id).toList();
    final resolvedWalletId =
        (_selectedWalletId != null && walletIds.contains(_selectedWalletId))
            ? _selectedWalletId!
            : (walletIds.isNotEmpty ? walletIds.first : null);

    if (resolvedWalletId == null || resolvedWalletId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada wallet — tambah dompet dulu.')),
      );
      return;
    }

    final kategoriSnapFresh = await _kategoriRef.get();
    final kategoriNames = kategoriSnapFresh.docs
        .map((d) => (d.data()['name'] ?? '').toString())
        .where((n) => n.isNotEmpty)
        .toList();
    final resolvedKategori =
        (_selectedKategori != null && kategoriNames.contains(_selectedKategori))
            ? _selectedKategori!
            : (kategoriNames.isNotEmpty ? kategoriNames.first : null);

    if (_type == 'expense' &&
        (resolvedKategori == null || resolvedKategori.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori')),
      );
      return;
    }

    final record = FirebaseFirestore.instance
        .collection('finance')
        .doc(widget.user)
        .collection('record');
    await record.add({
      'title': _titleC.text.trim(),
      if (_type == 'expense') 'kategori': resolvedKategori!.trim(),
      'time': _dateTime,
      'total': amount,
      'type': _type == 'income' ? 'Pemasukan' : 'Pengeluaran',
      'wallet': resolvedWalletId.trim(),
      'source': 'voice',
    });

    updateAmount(
      selectedWallet: resolvedWalletId.trim().toLowerCase(),
      selectedType: _type == 'income' ? 'pemasukan' : 'pengeluaran',
      totalAmount: amount,
      snapshot: AsyncSnapshot.withData(ConnectionState.done, walletSnap),
      wallet: _walletRef,
    );

    await _persistVoiceDefaults();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Catat Suara', style: myTextStyle(size: 18)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _VoiceState.idle:
        return _buildIdle();
      case _VoiceState.listening:
        return _buildListening();
      case _VoiceState.confirming:
        return _buildConfirming();
    }
  }

  Widget _buildIdle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: myTextStyle(color: Colors.red)),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PRIMARY_COLOR),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Default sebelum rekaman',
                        style:
                            myTextStyle(size: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _buildTypeToggle(),
                      const SizedBox(height: 8),
                      _buildWalletDropdown(),
                      if (_type == 'expense') _buildKategoriDropdown(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PRIMARY_COLOR),
                        ),
                        child: Text(
                          'Tap mic untuk mulai merekam, tap lagi pada mic untuk selesai.\n'
                          'Contoh: "pengeluaran indomaret 20 ribu jam 8 pagi"',
                          textAlign: TextAlign.center,
                          style: myTextStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _toggleMic,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: PRIMARY_COLOR),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 12)
                        ],
                      ),
                      child: Icon(Icons.mic, size: 60, color: PRIMARY_COLOR),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListening() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: PRIMARY_COLOR),
          ),
          child: Icon(Icons.graphic_eq, size: 60, color: PRIMARY_COLOR),
        ),
        const SizedBox(height: 16),
        Text('Mendengarkan… tap mic lagi untuk berhenti',
            style: myTextStyle(size: 18)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(
            _liveText.isEmpty ? '…' : _liveText,
            style: myTextStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _toggleMic,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: PRIMARY_COLOR),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 12)
              ],
            ),
            child: Icon(
              Icons.stop_circle_outlined,
              size: 60,
              color: PRIMARY_COLOR,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirming() {
    final parsed = _parsed;
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionColor: BG_COLOR,
        selectionHandleColor: PRIMARY_COLOR,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (parsed != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teks: ${parsed.rawText}',
                        style: myTextStyle(size: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Confidence: ${(parsed.confidence * 100).toStringAsFixed(0)}%'
                        '${parsed.ambiguous ? '  •  ambiguous' : ''}',
                        style: myTextStyle(
                          size: 12,
                          color: parsed.confidence >= 0.7
                              ? PRIMARY_COLOR
                              : Colors.grey,
                        ),
                      ),
                      if (parsed.missingFields.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Default dipakai untuk: ${parsed.missingFields.join(", ")}',
                          style: myTextStyle(size: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _buildTypeToggle(),
              const SizedBox(height: 12),
              PrimaryTextField(
                controller: _titleC,
                hintText: 'Judul',
                onChanged: (_) {},
              ),
              PrimaryTextField(
                controller: _amountC,
                hintText: 'Nominal',
                textInputType: TextInputType.number,
                onChanged: (data) {
                  final n =
                      int.tryParse(data.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                  _amountC.value = TextEditingValue(
                    text: formatToRupiah(n),
                    selection: TextSelection.collapsed(
                      offset: formatToRupiah(n).length,
                    ),
                  );
                },
              ),
              _buildWalletDropdown(),
              if (_type == 'expense') _buildKategoriDropdown(),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(_dateTime),
                          style: myTextStyle(),
                        ),
                      ),
                      Icon(Icons.calendar_today,
                          color: PRIMARY_COLOR, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: myElevatedButtonStyle(),
                      onPressed: () =>
                          setState(() => _state = _VoiceState.idle),
                      child: Text('Ulang', style: myTextStyle()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _save,
                      child: Text(
                        'Simpan',
                        style: myTextStyle(color: Colors.white),
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

  /// Sama pola dengan dialog tambah transaksi di [FinancialPage] (wallet = doc id).
  Widget _buildWalletDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _walletRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final docs = snapshot.data!.docs;
          final walletItems = docs.map<DropdownMenuItem<String>>((doc) {
            final data = doc.data();
            return DropdownMenuItem<String>(
              value: doc.id,
              child: Text(
                data['name']?.toString() ?? doc.id,
                style: myTextStyle(),
              ),
            );
          }).toList();
          final ids = docs.map((d) => d.id).toList();
          final displayWalletId =
              (_selectedWalletId != null && ids.contains(_selectedWalletId!))
                  ? _selectedWalletId
                  : (ids.isNotEmpty ? ids.first : null);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  iconEnabledColor: PRIMARY_COLOR,
                  style: myTextStyle(),
                  items: walletItems,
                  value:
                      displayWalletId != null && ids.contains(displayWalletId)
                          ? displayWalletId
                          : null,
                  onChanged: (v) {
                    setState(() => _selectedWalletId = v);
                    _persistVoiceDefaults();
                  },
                  hint: Text('Pilih Wallet', style: myTextStyle()),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: PRIMARY_COLOR),
                tooltip: 'Kelola Wallet',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Listwalletpage(wallet: _walletRef),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Sama seperti dropdown kategori di [FinancialPage] (nilai = nama).
  Widget _buildKategoriDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _kategoriRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final docs = snapshot.data!.docs;
          final items = docs.map<DropdownMenuItem<String>>((doc) {
            final name = doc.data()['name']?.toString() ?? '';
            return DropdownMenuItem<String>(
              value: name,
              child: Text(name, style: myTextStyle()),
            );
          }).toList();
          final names =
              items.map((e) => e.value!).where((n) => n.isNotEmpty).toList();
          final displayKategori =
              (_selectedKategori != null && names.contains(_selectedKategori))
                  ? _selectedKategori
                  : (names.isNotEmpty ? names.first : null);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: myTextStyle(),
                  iconEnabledColor: PRIMARY_COLOR,
                  items: items,
                  value:
                      displayKategori != null && names.contains(displayKategori)
                          ? displayKategori
                          : null,
                  onChanged: (v) {
                    setState(() => _selectedKategori = v);
                    _persistVoiceDefaults();
                  },
                  hint: Text('Pilih Kategori', style: myTextStyle()),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: PRIMARY_COLOR),
                tooltip: 'Kelola Kategori',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListCategoryPage(
                        kategori: _kategoriRef,
                        user: widget.user,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Selaras dengan toggle Pengeluaran/Pemasukan di dialog FinancialPage.
  Widget _buildTypeToggle() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _type = 'expense');
                _persistVoiceDefaults();
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: _type == 'expense' ? BG_COLOR : Colors.white,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(7),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Pengeluaran',
                  style: myTextStyle(
                    size: 14,
                    color: _type == 'expense' ? Colors.white : BG_COLOR,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _type = 'income');
                _persistVoiceDefaults();
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: _type == 'income' ? BG_COLOR : Colors.white,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(7),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Pemasukan',
                  style: myTextStyle(
                    size: 14,
                    color: _type == 'income' ? Colors.white : BG_COLOR,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (t == null) return;
    setState(
        () => _dateTime = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }
}
