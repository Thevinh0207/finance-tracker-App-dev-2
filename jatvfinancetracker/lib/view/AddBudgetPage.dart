import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Model/Budget.dart';
import '../viewModel/BudgetTrackerViewModel.dart';

class AddBudgetPage extends StatefulWidget {
  final String userID;
  final BudgetTrackerViewModel viewModel;

  const AddBudgetPage({
    super.key,
    required this.userID,
    required this.viewModel,
  });

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _newCategoryCtrl = TextEditingController();

  // null means "+ New category" is selected (or no categories exist).
  String? _selectedCategoryID;
  bool _useNewCategory = false;
  BudgetPeriod _period = BudgetPeriod.monthly;
  bool _saving = false;
  String? _saveError;

  static const _primaryBlue = Color(0xFF4A90D9);
  static const _darkText = Color(0xFF1A1A2E);
  static const _greyText = Color(0xFF888888);
  static const _dangerRed = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    final cats = widget.viewModel.availableCategories;
    if (cats.isNotEmpty) {
      _selectedCategoryID = cats.first.id;
      _useNewCategory = false;
    } else {
      _selectedCategoryID = null;
      _useNewCategory = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      await widget.viewModel.createBudget(
        userID: widget.userID,
        budgetName: _nameCtrl.text.trim(),
        categoryID: _useNewCategory ? null : _selectedCategoryID,
        newCategoryName: _useNewCategory ? _newCategoryCtrl.text.trim() : null,
        amount: double.parse(_amountCtrl.text.trim()),
        period: _period,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = 'Failed to save: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.viewModel.availableCategories;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'New Budget',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Set a spending limit for a category.',
                    style: TextStyle(fontSize: 13, color: _greyText),
                  ),
                  const SizedBox(height: 24),

                  _label('Budget Name'),
                  const SizedBox(height: 6),
                  _textField(
                    controller: _nameCtrl,
                    hint: 'e.g. Monthly Groceries',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter a budget name'
                        : null,
                  ),
                  const SizedBox(height: 18),

                  _label('Category'),
                  const SizedBox(height: 6),
                  _categoryPicker(categories),
                  if (_useNewCategory) ...[
                    const SizedBox(height: 10),
                    _textField(
                      controller: _newCategoryCtrl,
                      hint: 'New category name',
                      validator: (v) {
                        if (!_useNewCategory) return null;
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter a category name';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 18),

                  _label('Amount'),
                  const SizedBox(height: 6),
                  _textField(
                    controller: _amountCtrl,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    prefix: '\$',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter an amount';
                      final n = double.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Enter a positive number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  _label('Period'),
                  const SizedBox(height: 8),
                  _periodSelector(),
                  const SizedBox(height: 24),

                  if (_saveError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _dangerRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _saveError!,
                        style: const TextStyle(
                          color: _dangerRed,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _saving ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: _darkText),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Save Budget',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _darkText,
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: _darkText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _greyText, fontSize: 14),
        prefixText: prefix,
        prefixStyle: const TextStyle(
          color: _darkText,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _dangerRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _dangerRed, width: 1.5),
        ),
      ),
    );
  }

  Widget _categoryPicker(List<CategoryOption> categories) {
    if (categories.isEmpty) {
      // No existing categories — force the new-category flow.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: _primaryBlue, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Create your first category below',
                style: TextStyle(color: _primaryBlue, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    final dropdownValue = _useNewCategory ? null : _selectedCategoryID;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String?>(
          value: dropdownValue,
          isExpanded: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
          ),
          hint: const Text(
            'Select a category',
            style: TextStyle(color: _greyText, fontSize: 14),
          ),
          items: [
            ...categories.map(
              (c) => DropdownMenuItem<String?>(
                value: c.id,
                child: Text(
                  c.name,
                  style: const TextStyle(fontSize: 15, color: _darkText),
                ),
              ),
            ),
            const DropdownMenuItem<String?>(
              value: null,
              child: Text(
                '+ New category',
                style: TextStyle(
                  fontSize: 15,
                  color: _primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          onChanged: (val) {
            setState(() {
              _selectedCategoryID = val;
              _useNewCategory = val == null;
            });
          },
        ),
      ),
    );
  }

  Widget _periodSelector() {
    const periods = [
      (BudgetPeriod.weekly, 'Weekly'),
      (BudgetPeriod.monthly, 'Monthly'),
      (BudgetPeriod.yearly, 'Yearly'),
    ];
    return Row(
      children: periods.map((entry) {
        final selected = _period == entry.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.$1 == BudgetPeriod.yearly ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _period = entry.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? _primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? _primaryBlue : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    entry.$2,
                    style: TextStyle(
                      color: selected ? Colors.white : _darkText,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
