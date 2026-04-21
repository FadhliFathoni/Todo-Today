import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
import 'package:todo_today/views/Money/voice/models/parsed_finance.dart';
import 'package:todo_today/views/Money/voice/parser/finance_voice_parser.dart';
import 'package:todo_today/views/Money/voice/service/voice_input_service.dart';

enum _VoiceState { idle, listening, processing, confirming }

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
  late final TextEditingController _walletC;
  late final TextEditingController _categoryC;
  late DateTime _dateTime;
  late String _type;

  List<String> _wallets = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController();
    _amountC = TextEditingController();
    _walletC = TextEditingController();
    _categoryC = TextEditingController();
    _dateTime = DateTime.now();
    _type = 'expense';
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final fs = FirebaseFirestore.instance.collection('finance').doc(widget.user);
    final wSnap = await fs.collection('wallet').get();
    final cSnap = await fs.collection('kategori').get();
    setState(() {
      _wallets = wSnap.docs.map((d) => (d.data()['name'] ?? d.id).toString()).toList();
      _categories = cSnap.docs.map((d) => (d.data()['name'] ?? '').toString()).toList();
    });

    // permission_handler tidak mendaftarkan microphone di macOS/Windows/Linux
    // (MissingPluginException). Di desktop, izin biasanya diminta saat listen()
    // oleh engine speech_to_text / OS.
    await _requestMicPermissionIfMobile();
    await _voice.init(
      onStatus: (_) {},
      onError: (e) {
        setState(() {
          _error = e;
          _state = _VoiceState.idle;
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
    _walletC.dispose();
    _categoryC.dispose();
    _voice.cancel();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() {
      _liveText = '';
      _error = null;
      _state = _VoiceState.listening;
    });
    await _voice.start(
      onResult: (text, isFinal) {
        setState(() => _liveText = text);
        if (isFinal) _onFinalText(text);
      },
    );
  }

  Future<void> _stopListening() async {
    await _voice.stop();
    if (_liveText.isNotEmpty) {
      _onFinalText(_liveText);
    } else {
      setState(() => _state = _VoiceState.idle);
    }
  }

  void _onFinalText(String text) {
    setState(() => _state = _VoiceState.processing);
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
      _walletC.text = parsed.wallet;
      _categoryC.text = parsed.category;
      _dateTime = parsed.dateTime;
      _state = _VoiceState.confirming;
    });
  }

  Future<void> _save() async {
    final amount = convertRupiahToInt(_amountC.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal belum diisi')),
      );
      return;
    }

    final col = FirebaseFirestore.instance.collection('finance').doc(widget.user);
    final record = col.collection('record');
    final wallet = col.collection('wallet');

    await record.add({
      'title': _titleC.text.trim(),
      'kategori': _categoryC.text.trim(),
      'time': _dateTime,
      'total': amount,
      'type': _type == 'income' ? 'Pemasukan' : 'Pengeluaran',
      'wallet': _walletC.text.trim(),
      'source': 'voice',
    });

    final walletSnap = await wallet.get();
    updateAmount(
      selectedWallet: _walletC.text.trim().toLowerCase(),
      selectedType: _type == 'income' ? 'pemasukan' : 'pengeluaran',
      totalAmount: amount,
      snapshot: AsyncSnapshot.withData(ConnectionState.done, walletSnap),
      wallet: wallet,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG_COLOR,
      appBar: AppBar(
        backgroundColor: BG_COLOR,
        title: Text('Catat Suara', style: myTextStyle(size: 18)),
        elevation: 0,
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
      case _VoiceState.processing:
        return const Center(child: CircularProgressIndicator());
      case _VoiceState.confirming:
        return _buildConfirming();
    }
  }

  Widget _buildIdle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: myTextStyle(color: Colors.red)),
            ),
          Text(
            'Tap mic lalu ucapkan transaksi.\nContoh: "pengeluaran indomaret 20 ribu jam 8 pagi"',
            textAlign: TextAlign.center,
            style: myTextStyle(),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _startListening,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
              ),
              child: Icon(Icons.mic, size: 60, color: PRIMARY_COLOR),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListening() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.graphic_eq, size: 80, color: PRIMARY_COLOR),
        const SizedBox(height: 16),
        Text('Mendengarkan...', style: myTextStyle(size: 18)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _liveText.isEmpty ? '...' : _liveText,
            style: myTextStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _stopListening,
          icon: const Icon(Icons.stop),
          label: const Text('Selesai'),
        ),
      ],
    );
  }

  Widget _buildConfirming() {
    final parsed = _parsed;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (parsed != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Teks: ${parsed.rawText}', style: myTextStyle(size: 14)),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: ${(parsed.confidence * 100).toStringAsFixed(0)}%'
                    '${parsed.ambiguous ? '  •  ambiguous' : ''}',
                    style: myTextStyle(
                      size: 12,
                      color: parsed.confidence >= 0.7 ? Colors.green : Colors.orange,
                    ),
                  ),
                  if (parsed.missingFields.isNotEmpty)
                    Text(
                      'Default dipakai untuk: ${parsed.missingFields.join(", ")}',
                      style: myTextStyle(size: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: _typeChip(label: 'Pengeluaran', value: 'expense'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _typeChip(label: 'Pemasukan', value: 'income'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field('Judul', _titleC),
          _field('Nominal', _amountC, keyboardType: TextInputType.number),
          _field('Wallet', _walletC),
          _field('Kategori', _categoryC),
          const SizedBox(height: 8),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(DateFormat('dd MMM yyyy, HH:mm').format(_dateTime),
                style: myTextStyle()),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDateTime,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _state = _VoiceState.idle),
                  child: const Text('Ulang'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
                  onPressed: _save,
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeChip({required String label, required String value}) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? PRIMARY_COLOR : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: myTextStyle(color: selected ? Colors.white : PRIMARY_COLOR),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (v) {
          if (label == 'Nominal') {
            final n = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            c.value = TextEditingValue(
              text: formatToRupiah(n),
              selection: TextSelection.collapsed(offset: formatToRupiah(n).length),
            );
          }
        },
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
    setState(() => _dateTime = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }
}
