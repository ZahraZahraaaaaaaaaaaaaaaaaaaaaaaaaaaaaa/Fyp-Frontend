import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

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
    final type = node.type.toLowerCase();
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

/// Signals a successful login to Flutter autofill + browser credential APIs.
Future<void> onLoginSuccessForBrowser({
  required String email,
  required String password,
}) async {
  TextInput.finishAutofillContext(shouldSave: true);
  await _storeViaCredentialManagementApi(email, password);
  // Keep login route visible briefly so Chrome can show "Save password?"
  await Future<void>.delayed(const Duration(milliseconds: 450));
}

Future<void> _storeViaCredentialManagementApi(String email, String password) async {
  if (!js.context.hasProperty('PasswordCredential')) return;
  try {
    final cred = js.JsObject(
      js.context['PasswordCredential'],
      [
        js.JsObject.jsify({
          'id': email,
          'password': password,
          'name': email,
        }),
      ],
    );
    final credentials = js.context['navigator']['credentials'];
    if (credentials == null) return;
    await js_util.promiseToFuture(js_util.callMethod(credentials, 'store', [cred]));
  } catch (_) {
    // User dismissed, unsupported context, or browser policy — Flutter autofill may still work.
  }
}
