import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../logic/calculator.dart';
import '../logic/currency.dart';

class ResultScreen extends StatelessWidget {
  final String title;
  final String expression;
  final Map<String, String> rawQuery;
  final String backPath;
  final bool isCalculator;
  final VoidCallback onToggleTheme;

  const ResultScreen({
    super.key,
    required this.title,
    required this.expression,
    required this.rawQuery,
    required this.backPath,
    required this.isCalculator,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    late final Widget resultWidget;

    if (isCalculator) {
      final result = calculate(
        rawQuery['a'],
        rawQuery['op'],
        rawQuery['b'],
      );
      resultWidget = switch (result) {
        CalcSuccess(:final value) => _SuccessCard(
            expression: expression,
            value: formatResult(value),
          ),
        CalcFailure(:final message) => _ErrorCard(message: message),
      };
    } else {
      final result = convert(
        rawQuery['amount'],
        rawQuery['from'],
        rawQuery['to'],
      );
      resultWidget = switch (result) {
        ConvertSuccess(:final value) => _SuccessCard(
            expression: expression,
            value: formatCurrency(value),
          ),
        ConvertFailure(:final message) => _ErrorCard(message: message),
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Сменить тему',
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                resultWidget,
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.go(backPath),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Вернуться к форме'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('На главную'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final String expression;
  final String value;

  const _SuccessCard({required this.expression, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              expression,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}