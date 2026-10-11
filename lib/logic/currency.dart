/// Курсы относительно рубля (примерные константы).
const Map<String, double> ratesToRub = {
  'RUB': 1.0,
  'USD': 95.0,
  'EUR': 102.0,
  'CNY': 13.2,
  'GBP': 120.0,
  'JPY': 0.63,
};

const List<String> supportedCurrencies = [
  'RUB',
  'USD',
  'EUR',
  'CNY',
  'GBP',
  'JPY',
];

sealed class ConvertResult {
  const ConvertResult();
}

class ConvertSuccess extends ConvertResult {
  final double value;
  const ConvertSuccess(this.value);
}

class ConvertFailure extends ConvertResult {
  final String message;
  const ConvertFailure(this.message);
}

ConvertResult convert(String? rawAmount, String? from, String? to) {
  final amount = double.tryParse(rawAmount?.replaceAll(',', '.') ?? '');
  if (amount == null) {
    return const ConvertFailure('В адресе передана некорректная сумма');
  }
  if (from == null || !ratesToRub.containsKey(from)) {
    return const ConvertFailure('Неизвестная исходная валюта');
  }
  if (to == null || !ratesToRub.containsKey(to)) {
    return const ConvertFailure('Неизвестная целевая валюта');
  }

  // Конвертируем через рубль
  final inRub = amount * ratesToRub[from]!;
  final result = inRub / ratesToRub[to]!;
  return ConvertSuccess(result);
}

String formatCurrency(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  final s = value.toStringAsFixed(4);
  return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}