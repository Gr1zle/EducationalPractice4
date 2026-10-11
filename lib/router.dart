import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/result_screen.dart';
import 'screens/not_found_screen.dart';

GoRouter createRouter({required VoidCallback onToggleTheme}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(onToggleTheme: onToggleTheme),
      ),
      GoRoute(
        path: '/calculator',
        builder: (context, state) =>
            CalculatorScreen(onToggleTheme: onToggleTheme),
        routes: [
          // Вложенный маршрут: итоговый адрес — /calculator/result
          GoRoute(
            path: 'result',
            builder: (context, state) {
              final q = state.uri.queryParameters;
              return ResultScreen(
                title: 'Результат вычисления',
                expression: '${q['a'] ?? '?'} ${q['op'] ?? '?'} ${q['b'] ?? '?'}',
                rawQuery: q,
                backPath: '/calculator',
                isCalculator: true,
                onToggleTheme: onToggleTheme,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/converter',
        builder: (context, state) =>
            ConverterScreen(onToggleTheme: onToggleTheme),
        routes: [
          GoRoute(
            path: 'result',
            builder: (context, state) {
              final q = state.uri.queryParameters;
              return ResultScreen(
                title: 'Результат конвертации',
                expression:
                    '${q['amount'] ?? '?'} ${q['from'] ?? '?'} → ${q['to'] ?? '?'}',
                rawQuery: q,
                backPath: '/converter',
                isCalculator: false,
                onToggleTheme: onToggleTheme,
              );
            },
          ),
        ],
      ),
    ],
    // Аналог страницы 404
    errorBuilder: (context, state) => NotFoundScreen(
      location: state.uri.toString(),
      onToggleTheme: onToggleTheme,
    ),
  );
}