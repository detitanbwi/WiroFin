import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/database_helper.dart';
import '../../widgets/top_toast.dart';

class CategorySettingsPage extends StatefulWidget {
  final String activeMode;
  const CategorySettingsPage({super.key, required this.activeMode});

  @override
  State<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

class _CategorySettingsPageState extends State<CategorySettingsPage> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  late String _currentType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.activeMode;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final categories = await DatabaseHelper.instance.getCategories(_currentType);
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? item}) {
    final TextEditingController nameController = TextEditingController(text: item?['name'] ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              item == null
                  ? (AppLocalizations.of(context)?.addCategory ?? 'Tambah Kategori')
                  : (AppLocalizations.of(context)?.editCategory ?? 'Edit Kategori'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)?.categoryName ?? 'Nama Kategori',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)?.cancel ?? 'Batal', style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final data = {'name': nameController.text.trim(), 'type': _currentType, 'transaction_type': 'general'};
                    if (item == null) {
                      await DatabaseHelper.instance.insertCategory(data);
                    } else {
                      await DatabaseHelper.instance.updateCategory(item['id'], data);
                    }
                    Navigator.pop(context);
                    _loadData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(AppLocalizations.of(context)?.save ?? 'Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteItem(String id, String name) async {
    if (name == 'Other') {
      TopToast.show(context, AppLocalizations.of(context)?.defaultCategoryError ?? 'Kategori default "Other" tidak dapat dihapus.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.deleteDataTitle ?? 'Hapus Data'),
        content: Text(AppLocalizations.of(context)?.confirmDeleteCategory ?? 'Apakah Anda yakin ingin menghapus kategori ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)?.cancel ?? 'Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)?.delete ?? 'Hapus', style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteCategory(id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.transactionCategory ?? 'Kategori Transaksi', style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'personal', label: Text('Pribadi')),
                  ButtonSegment(value: 'company', label: Text('Perusahaan')),
                ],
                selected: {_currentType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _currentType = newSelection.first;
                  });
                  _loadData();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).primaryColor.withOpacity(0.1);
                    }
                    return Colors.white;
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)?.emptyCategory ?? 'Belum ada data kategori', style: TextStyle(color: Colors.grey.shade400)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _categories[index];
                    final isOther = item['name'] == 'Other';

                    return ListTile(
                      title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: isOther
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                              child: Text(AppLocalizations.of(context)?.defaultLabel ?? 'Default', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showAddEditDialog(item: item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteItem(item['id'], item['name']),
                                ),
                              ],
                            ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
