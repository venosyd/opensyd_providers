///
/// venosyd © 2016-2021. sergio lisan <sels@venosyd.com>
///
library opensyd.dart.providers.exoservices.aws;

import 'dart:async';
import 'dart:convert';

import 'package:opensyd_dart/opensyd_dart.dart';

import '../login.dart';
import '../util/_module_.dart';

///
/// provedor de carregamento de imagens
///
class AWSProvider {
  ///
  AWSProvider(String host, this.login)
      : _http = HttpProvider(
          host: host,
          api: {
            'AWS_BASE_URI': '/aws',
            'AWS_S3_UPLOAD': '/s3/upload',
          },
        );

  ///
  final HttpProvider _http;

  ///
  final LoginProvider login;

  ///
  Future<String> s3upload({
    String bucket,
    String key,
    String file,
  }) async {
    final payload = {
      'bucket': bucket,
      'key': key,
      'file': file,
    };

    final response = await _http.post(
      [
        'AWS_BASE_URI',
        'AWS_S3_UPLOAD',
      ],
      payload,
      headers: {
        'Authorization':
            'Basic ${base64.encode((await login.token).codeUnits)}',
      },
    );

    return response['status'] == 'ok' //
        ? Responses.SUCCESS
        : Responses.FAILURE;
  }
}
