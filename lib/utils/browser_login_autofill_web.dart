import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/services.dart';

/// Tags Flutter Web <input> elements so Chrome can detect a login form.
Future<void> prepareLoginFieldsForBrowser() async {
  for (final ms in [0, 80, 200, 500]) {
    if (ms > 0) {
      await Future<void>.delayed(Duration(milliseconds: ms));
    }
    _tagLoginInputs();
  }
}

void _tagLoginInputs() {
  html.InputElement? passwordInput;
  final textLikeInputs = <html.InputElement>[];

  for (final node in html.document.querySelectorAll('input')) {
    if (node is! html.InputElement) continue;
    final type = (node.type ?? '').toLowerCase();
    if (type == 'password') {
      passwordInput = node;
    } else if (type == 'email' || type == 'text' || type.isEmpty) {
      textLikeInputs.add(node);
    }
  }

  final emailInput = textLikeInputs.isNotEmpty ? textLikeInputs.first : null;
  if (emailInput != null) {
    emailInput
      ..autocomplete = 'username'
      ..name = 'username'
      ..id = 'username';
  }
  if (passwordInput != null) {
    passwordInput
      ..autocomplete = 'current-password'
      ..name = 'password'
      ..id = 'password';
  }
}

/// Signals a successful login to Flutter autofill (browser may offer to save password).
Future<void> onLoginSuccessForBrowser({
  required String email,
  required String password,
}) async {
  TextInput.finishAutofillContext(shouldSave: true);
  // Keep login route visible briefly so Chrome can show "Save password?"
  await Future<void>.delayed(const Duration(milliseconds: 450));
}
