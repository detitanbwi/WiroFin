import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/nlp_service.dart';
import 'top_toast.dart';

class NlpInputDialog extends StatefulWidget {
  final String activeMode;

  const NlpInputDialog({super.key, required this.activeMode});

  static Future<NlpParseResult?> show(BuildContext context, {required String activeMode}) {
    return showModalBottomSheet<NlpParseResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 24,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: NlpInputDialog(activeMode: activeMode),
      ),
    );
  }

  @override
  State<NlpInputDialog> createState() => _NlpInputDialogState();
}

class _NlpInputDialogState extends State<NlpInputDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;

  Future<void> _processText(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final res = await NlpService.instance.parseSentence(text);
      if (mounted) {
        Navigator.pop(context, res); // Close NLP dialog and return result
      }
    } catch (e) {
      if (mounted) {
        String msg = AppLocalizations.of(context)?.nlpErrorProcess ?? "Gagal memproses kalimat";
        if (e is Exception) {
          final errStr = e.toString();
          if (errStr.contains('Nominal transaksi tidak ditemukan') || errStr.toLowerCase().contains('amount not found')) {
            msg = AppLocalizations.of(context)?.nlpErrorNoAmount ?? "Nominal transaksi tidak ditemukan";
          } else {
            msg = errStr.replaceAll('Exception: ', '');
          }
        }
        TopToast.show(context, msg, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final List<String> suggestions = [
      localizations?.nlpSample1 ?? "Ngopi kopi kenangan 28k",
      localizations?.nlpSample2 ?? "Gaji bulanan masuk 5jt",
      localizations?.nlpSample3 ?? "Beli bensin pertamax 50rb kemaren",
      localizations?.nlpSample4 ?? "Makan siang warteg 20000",
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.auto_awesome, color: Colors.deepPurple.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations?.nlpTitle ?? "Pencatatan Cerdas (NLP)",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      localizations?.nlpSubtitle ?? "Ketik kalimat kasual, WiroFin otomatis mengisinya",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 2,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: localizations?.nlpExampleHint ?? "Contoh: Beli bensin 50rb kemaren...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 2),
              ),
              suffixIcon: _isProcessing
                  ? const Padding(
                       padding: EdgeInsets.all(12.0),
                       child: CircularProgressIndicator(strokeWidth: 2),
                     )
                  : IconButton(
                      icon: Icon(Icons.send, color: Colors.deepPurple.shade600),
                      onPressed: () => _processText(_controller.text),
                    ),
            ),
            onSubmitted: _processText,
          ),
          const SizedBox(height: 20),
          Text(
            localizations?.nlpTrySentence ?? "Coba kalimat berikut:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((sug) => ActionChip(
              label: Text(sug, style: TextStyle(color: Colors.deepPurple.shade700, fontSize: 13)),
              backgroundColor: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide.none,
              onPressed: () {
                _controller.text = sug;
                _processText(sug);
              },
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
      ),
    );
  }
}
