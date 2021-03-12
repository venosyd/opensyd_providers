///
/// venosyd © 2016-2021
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.http;

import 'dart:async';
import 'dart:convert';

// import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

///
/// Servico provedor de funcoes http (post e get no momento)
/// Processa as requisicoes e retorna um mapa de respostas
///
class HttpProvider {
  ///
  const HttpProvider({this.host, this.api});

  ///
  final Map<String, String> api;

  ///
  final String host;

  ///
  Future<Map<String, dynamic>> post(
    List<String> apis,
    Map<String, dynamic> payload, {
    Map<String, String> headers,
  }) async =>
      await postURL(_buildURL(apis), payload, headers: headers);

  ///
  Future<Map<String, dynamic>> get(
    List<String> apis, {
    List<String> params = const [],
    Map<String, String> headers,
  }) async =>
      await getURL(
        '${_buildURL(apis)}${_buildParams(params)}',
        headers: headers,
      );

  ///
  Future<Map<String, dynamic>> postURL(
    String url,
    Map<String, dynamic> payload, {
    Map<String, String> headers,
    bool isjson = true,
  }) async {
    http.Response httpresponse;

    headers ??= {};

    if (isjson) {
      headers['Content-Type'] = 'application/json';
    }

    try {
      httpresponse = await http.post(
        Uri.parse(url),
        body: json.encode(payload), // _compress(json.encode(payload)),
        headers: headers,
      );

      return json.decode(utf8.decode(
              httpresponse.body.codeUnits)) // _decompress(httpresponse.body))
          as Map<String, dynamic>;
    }
    //
    catch (p, e) {
      print('HTTPPROVIDER POST - $p');
      print('HTTPPROVIDER POST - $e');
      print('HTTPPROVIDER POST - ${httpresponse.body}');
    }

    return <String, dynamic>{'status': 'error'};
  }

  ///
  Future<Map<String, dynamic>> getURL(
    String url, {
    Map<String, String> headers,
  }) async {
    http.Response httpresponse;

    try {
      httpresponse = await http.get(Uri.parse(url), headers: headers ?? {});
      return json.decode(utf8.decode(httpresponse.body.codeUnits))
          as Map<String, dynamic>;
    }
    //
    catch (p, e) {
      print('HTTPPROVIDER GET - $p');
      print('HTTPPROVIDER GET - $e');
      print('HTTPPROVIDER GET - ${httpresponse.body}');
    }

    return <String, dynamic>{'status': 'error'};
  }

  /// data uma lista de paths monta a URL da API
  String _buildURL(List<String> paths) {
    var url = '';
    paths.forEach((path) => url += api[path]);

    return '$host$url';
  }

  /// data uma lista de paths monta a URL da API
  String _buildParams(List<String> params) {
    var result = '';
    params.forEach((param) => result += '/$param');

    return result;
  }

  // ///
  // String _compress(String origin) {
  //   final gzip = GZipEncoder();
  //   final zipped = gzip.encode(utf8.encode(origin));

  //   return base64.encode(zipped);
  // }

  // ///
  // String _decompress(String origin) {
  //   final gzip = GZipDecoder();
  //   final data = base64.decode(origin);

  //   return utf8.decode(gzip.decodeBytes(data));
  // }
}
