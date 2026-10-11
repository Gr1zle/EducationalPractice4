import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/currency.dart';

class ConverterScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ConverterScreen({super.key, required this.onToggleTheme});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _from = 'USD';
  String _to = 'RUB';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadLastPair();
  }

  Future<void> _loadLastPair() async {
    final prefs = await SharedPreferences.getInstance();
    final from = prefs.getString('converter_from');
    final to = prefs.getString('converter_to');
    if (from != null && supportedCurrencies.contains(from)) {
      _from = from;
    }
    if (to != null && supportedCurrencies.contains(to)) {
      _to = to;
    }
    if (mounted) {
      setState(() => _loaded = true);
    }
  }

  Future<void> _saveLastPair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('converter_from', _from);
    await prefs.setString('converter_to', _to);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите сумму';
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Это не число';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = _amountController.text.replaceAll(',', '.');
    _saveLastPair();

    context.go(
      '/converter/result?amount=$amount&from=$_from&to=$_to',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Конвертер валют')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Сменить тему',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Сумма',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _amountValidator,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _from,
                    decoration: const InputDecoration(
                      labelText: 'Из валюты',
                      border: OutlineInputBorder(),
                    ),
                    items: supportedCurrencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _from = value ?? 'USD'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _to,
                    decoration: const InputDecoration(
                      labelText: 'В валюту',
                      border: OutlineInputBorder(),
                    ),
                    items: supportedCurrencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) => setState(() => _to = value ?? 'RUB'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Конвертировать'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('На главную'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}