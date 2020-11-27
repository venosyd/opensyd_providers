///
/// venosyd © 2016-2020
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.mail;

import 'dart:async';
import 'dart:convert';

import 'package:opensyd_dart/opensyd_dart.dart';

import 'login.dart';
import 'util/_module_.dart';

///
/// provedor de carregamento de imagens
///
class MailProvider {
  ///
  MailProvider(String host, this.login)
      : _http = HttpProvider(
          host: host,
          api: _MailAPI.api,
        );

  ///
  factory MailProvider.build(
    bool devmode,
    LoginProvider login, {
    bool securedev = false,
  }) =>
      MailProvider(
        mailHost(devmode, securedev),
        login,
      );

  ///
  final HttpProvider _http;

  ///
  final LoginProvider login;

  ///
  Future<String> send({
    String passwd,
    String from,
    String fromName,
    String emails,
    String title,
    String html,
  }) async {
    final payload = {
      'hash': '${login.logindb}$passwd',
      'from': from,
      'fromName': fromName,
      'emails': emails,
      'title': title,
      'payload': html,
    };

    final response = await _http.post(
        [
          'MAIL_BASE_URI',
          'MAIL_SEND',
        ],
        payload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    return response['status'] == 'ok' ? Responses.SUCCESS : Responses.FAILURE;
  }
}

///
abstract class _MailAPI {
  static final Map<String, String> api = {
    'MAIL_BASE_URI': '/mail',
    'MAIL_SEND': '/send',
  };
}
