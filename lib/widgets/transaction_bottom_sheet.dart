import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/database_helper.dart';
import 'custom_numpad.dart';
import 'top_toast.dart';

class TransactionBottomSheet extends StatefulWidget {
  final String activeMode; // 'personal' or 'company'
  final Map<String, dynamic>? initialTransaction;
  
  const TransactionBottomSheet({
    super.key,
    required this.activeMode,
    this.initialTransaction,
  });

  @override
  State<TransactionBottomSheet> createState() => _TransactionBottomSheetState();
}

class _TransactionBottomSheetState extends State<TransactionBottomSheet> {
  late String _amount;
  late String _description;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  late TextEditingController _descriptionController;

  String _transactionType = 'expense';
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;
  late String _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialTransaction?['type'] ?? widget.activeMode;
    if (widget.initialTransaction != null) {
      _amount = widget.initialTransaction!['amount'].toString();
      _description = widget.initialTransaction!['description'] ?? '';
      _selectedCategoryId = widget.initialTransaction!['category_id'];
      _selectedAccountId = widget.initialTransaction!['account_id'];
      _transactionType = widget.initialTransaction!['transaction_type'] ?? 'expense';
    } else {
      _amount = '';
      _description = '';
    }
    _descriptionController = TextEditingController(text: _description);
    _loadMasterData();
  }

  List<Map<String, dynamic>> get _filteredCategories {
    return _categories;
  }

  void _updateSelectedCategory() {
    final filtered = _filteredCategories;
    if (filtered.isEmpty) {
      _selectedCategoryId = null;
    } else if (_selectedCategoryId == null || !filtered.any((c) => c['id'] == _selectedCategoryId)) {
      _selectedCategoryId = filtered.first['id'];
    }
  }

  void _switchType(String type) {
    if (_transactionType != type) {
      setState(() {
        _transactionType = type;
        _updateSelectedCategory();
      });
    }
  }

  Future<void> _loadMasterData() async {
    final cats = await DatabaseHelper.instance.getCategories(_currentMode);
    final accs = await DatabaseHelper.instance.getAccounts(_currentMode);
    setState(() {
      _categories = cats;
      _accounts = accs;
      _updateSelectedCategory();
      if (_selectedAccountId == null && accs.isNotEmpty) {
        _selectedAccountId = accs.first['id'];
      }
      _isLoading = false;
    });
  }

  void _toggleMode() async {
    setState(() {
      _currentMode = _currentMode == 'personal' ? 'company' : 'personal';
      _isLoading = true;
    });
    
    final cats = await DatabaseHelper.instance.getCategories(_currentMode);
    final accs = await DatabaseHelper.instance.getAccounts(_currentMode);
    
    setState(() {
      _categories = cats;
      _accounts = accs;
      
      // Try to find matching category by name
      final currentCategoryName = _categories.firstWhere(
        (c) => c['id'] == _selectedCategoryId, 
        orElse: () => {'name': ''}
      )['name'];
      
      _selectedCategoryId = null;
      if (currentCategoryName != '') {
        for (var cat in cats) {
          if (cat['name'].toString().toLowerCase() == currentCategoryName.toString().toLowerCase()) {
            _selectedCategoryId = cat['id'];
            break;
          }
        }
      }
      if (_selectedCategoryId == null && cats.isNotEmpty) {
        for (var cat in cats) {
          if (cat['name'].toString().toLowerCase() == 'other' || cat['name'].toString().toLowerCase() == 'lainnya') {
            _selectedCategoryId = cat['id'];
            break;
          }
        }
        _selectedCategoryId ??= cats.first['id'];
      }

      // Try to find matching account by name
      final currentAccountName = _accounts.firstWhere(
        (a) => a['id'] == _selectedAccountId, 
        orElse: () => {'name': ''}
      )['name'];
      
      _selectedAccountId = null;
      if (currentAccountName != '') {
        for (var acc in accs) {
          if (acc['name'].toString().toLowerCase() == currentAccountName.toString().toLowerCase()) {
            _selectedAccountId = acc['id'];
            break;
          }
        }
      }
      if (_selectedAccountId == null && accs.isNotEmpty) {
        _selectedAccountId = accs.first['id'];
      }
      
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_amount.length < 12) {
      setState(() {
        _amount += number;
      });
    }
  }

  void _onClear() {
    setState(() {
      _amount = '';
    });
  }

  void _onBackspace() {
    if (_amount.isNotEmpty) {
      setState(() {
        _amount = _amount.substring(0, _amount.length - 1);
      });
    }
  }

  String get _formattedAmount {
    if (_amount.isEmpty) return '0';
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(int.parse(_amount));
  }

  void _onSave() {
    if (_amount.isEmpty || _amount == '0') {
      TopToast.show(context, AppLocalizations.of(context)?.amountEmptyError ?? 'Nominal tidak boleh kosong', isError: true);
      return;
    }
    
    Navigator.pop(context, {
      'amount': int.parse(_amount),
      'description': _description,
      'category_id': _selectedCategoryId,
      'account_id': _selectedAccountId,
      'type': _currentMode,
      'transaction_type': _transactionType,
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = _currentMode == 'personal' ? Colors.orange.shade600 : Colors.teal.shade600;
    
    if (_isLoading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _currentMode == 'personal' 
              ? const Color(0xFFFFF7ED) // Very light warm orange background
              : const Color(0xFFF0FDF4), // Very light cool teal background
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialTransaction != null
                        ? (AppLocalizations.of(context)?.editTransaction ?? 'Edit Transaksi')
                        : (AppLocalizations.of(context)?.recordTransaction ?? 'Catat Transaksi'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.initialTransaction != null)
                        InkWell(
                          onTap: _toggleMode,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: themeColor.withOpacity(0.3), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _currentMode == 'personal' ? Icons.person : Icons.business,
                                  size: 14,
                                  color: themeColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _currentMode == 'personal' ? 'Pribadi' : 'Usaha',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.swap_horiz,
                                  size: 12,
                                  color: themeColor.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: themeColor.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _currentMode == 'personal' ? Icons.person : Icons.business,
                                size: 14,
                                color: themeColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _currentMode == 'personal' ? 'Pribadi' : 'Usaha',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
            
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Control
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _switchType('expense'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _transactionType == 'expense' ? Colors.red.shade600 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _transactionType == 'expense' 
                                      ? [BoxShadow(color: Colors.red.shade200, blurRadius: 8, offset: const Offset(0, 2))] 
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)?.expense ?? 'Pengeluaran',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _transactionType == 'expense' ? Colors.white : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _switchType('income'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _transactionType == 'income' ? Colors.green.shade600 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _transactionType == 'income' 
                                      ? [BoxShadow(color: Colors.green.shade200, blurRadius: 8, offset: const Offset(0, 2))] 
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)?.income ?? 'Pemasukan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _transactionType == 'income' ? Colors.white : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Amount Display
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rp ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: _amount.isEmpty ? Colors.grey.shade400 : const Color(0xFF1E293B),
                                height: 1.5,
                              ),
                            ),
                            Text(
                              _formattedAmount,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: _amount.isEmpty ? Colors.grey.shade400 : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),

                    // Description Input
                    TextField(
                      controller: _descriptionController,
                      onChanged: (val) => _description = val,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)?.descriptionOptional ?? 'Keterangan (Opsional)',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.edit_note, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // Category & Account Dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategoryId,
                                isExpanded: true,
                                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w500),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategoryId = newValue;
                                  });
                                },
                                items: _filteredCategories.map<DropdownMenuItem<String>>((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat['id'],
                                    child: Text(cat['name']),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedAccountId,
                                isExpanded: true,
                                hint: Text('Pilih Rekening', style: TextStyle(color: Colors.grey.shade400)),
                                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w500),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedAccountId = newValue;
                                  });
                                },
                                items: _accounts.map<DropdownMenuItem<String>>((acc) {
                                  return DropdownMenuItem<String>(
                                    value: acc['id'],
                                    child: Text(acc['name']),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),

                    // Numpad (Pindah ke dalam scroll view agar tidak overflow saat keyboard muncul)
                    Container(
                      padding: const EdgeInsets.only(bottom: 24, top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ]
                      ),
                      child: CustomNumpad(
                        onNumberPressed: _onNumberPressed,
                        onClear: _onClear,
                        onBackspace: _onBackspace,
                        onSave: _onSave,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
