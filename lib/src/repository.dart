///
/// venosyd © 2016-2021
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.repository;

import 'dart:async';
import 'dart:convert';

import 'package:opensyd_dart/opensyd_dart.dart';

import 'login.dart';
import 'util/_module_.dart';

///
/// servico de armazenagem nosql de dados
///
class RepositoryProvider {
  ///
  RepositoryProvider(String host, this.login)
      : _http = HttpProvider(
          host: host,
          api: _RepositoryAPI.api,
        );

  ///
  factory RepositoryProvider.build(
    bool devmode,
    LoginProvider login, {
    bool securedev = false,
  }) =>
      RepositoryProvider(
        repositoryHost(devmode, securedev),
        login,
      );

  ///
  final HttpProvider _http;

  ///
  final LoginProvider login;

  ///
  // final Map<int, FutureOr<Map<String, dynamic>>> requests = {};

  ///
  Future<Map<String, dynamic>> getByID({
    String authkey,
    String token,
    String logindb,
    String database,
    String collection,
    dynamic id,
  }) async {
    final payload = {
      'hash': '$authkey$database$logindb',
      'collection': collection,
      'id': '$id',
    };

    final response = await _http.post(
        [
          'REPOSITORY_BASE_URI',
          'REPOSITORY_GET_ID',
        ],
        payload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    if (response['status'] == 'ok' && response['payload'] != '[]') {
      return json.decode(response['payload'] as String) as Map<String, dynamic>;
    }

    return <String, dynamic>{};
  }

  ///
  Future<Map<String, dynamic>> getByQuery({
    String authkey,
    String token,
    String logindb,
    String database,
    String collection,
    Map<String, dynamic> query,
  }) async {
    final payload = {
      'hash': '$authkey$database$logindb',
      'collection': collection,
      'query': json.encode(query),
    };

    final response = await _http.post(
        [
          'REPOSITORY_BASE_URI',
          'REPOSITORY_GET_QUERY',
        ],
        payload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    if (response['status'] == 'ok' && response['payload'] != '[]') {
      return json.decode(response['payload'] as String) as Map<String, dynamic>;
    }

    return <String, dynamic>{};
  }

  ///
  Future<List<Map<String, dynamic>>> list({
    String authkey,
    String token,
    String logindb,
    String database,
    String collection,
    Map<String, dynamic> query,
  }) async {
    final payload = {
      'hash': '$authkey$database$logindb',
      'collection': collection,
      'query': json.encode(query),
    };

    final response = await _http.post(
        [
          'REPOSITORY_BASE_URI',
          'REPOSITORY_LIST',
        ],
        payload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    return (response['status'] == 'ok')
        ? json
            .decode(response['payload'] as String)
            .map((dynamic e) => json.decode(e as String))
            .toList()
            .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>
        : [];
  }

  ///
  Future<List<Map<String, dynamic>>> listIDs({
    String authkey,
    String token,
    String logindb,
    String database,
    String collection,
    Map<String, dynamic> query,
  }) async {
    final payload = {
      'hash': '$authkey$database$logindb',
      'collection': collection,
      'query': json.encode(query),
    };

    final response = await _http.post(
        [
          'REPOSITORY_BASE_URI',
          'REPOSITORY_LIST_ALL_IDS',
        ],
        payload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    return (response['status'] == 'ok')
        ? json
            .decode(response['payload'] as String)
            .map((dynamic e) => json.decode(e as String))
            .toList()
            .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>
        : [];
  }

  ///
  Future<List<Map<String, dynamic>>> listDistinct({
    String authkey,
    String token,
    String logindb,
    String database,
    String collection,
    String field,
    Map<String, dynamic> query,
  }) async {
    final payload = {
      'hash': '$authkey$database$logindb',
      'collection': collection,
      'field': field,
      'query': json.encode(query),
    };

    final response = await _http.post(
        [
          'REPOSITORY_BASE_URI',
          'REPOSITORY_LIST_DISTINCT',
        ],
        payload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    return (response['status'] == 'ok')
        ? json
            .decode(response['payload'] as String)
            .map((dynamic e) => json.decode(e as String))
            .toList()
            .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>
        : [];
  }

  ///
  Future<Map<String, dynamic>> save({
    String authkey,
    String token,
    String logindb,
    String database,
    Map<String, dynamic> payload,
  }) async {
    final mPayload = {
      'hash': '$authkey$database$logindb',
      'payload': json.encode(payload),
    };

    final response = await _http.post(
        [
          'REPOSITORY_BASE_URI',
          'REPOSITORY_SAVE',
        ],
        mPayload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    if (response['status'] == 'ok') {
      return json.decode(response['payload'] as String) as Map<String, dynamic>;
    }

    return <String, dynamic>{};
  }

  ///
  Future<Map<String, dynamic>> update({
    String authkey,
    String token,
    String logindb,
    String database,
    Map<String, dynamic> payload,
  }) async {
    final mPayload = {
      'hash': '$authkey$database$logindb',
      'payload': json.encode(payload),
    };

    final response = await _http.post(
        [
          'REPOSITORY_BASE_URI',
          'REPOSITORY_UPDATE',
        ],
        mPayload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    if (response['status'] == 'ok') {
      return json.decode(response['payload'] as String) as Map<String, dynamic>;
    }

    return <String, dynamic>{};
  }

  ///
  Future<String> erase({
    String authkey,
    String token,
    String logindb,
    String database,
    Map<String, dynamic> payload,
  }) async {
    final mPayload = {
      'hash': '$authkey$database$logindb',
      'payload': json.encode(payload),
    };

    final response = await _http.post(
        [
          'REPOSITORY_BASE_URI',
          'REPOSITORY_ERASE',
        ],
        mPayload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    return response['status'] == 'ok' ? Responses.SUCCESS : Responses.FAILURE;
  }
}

///
abstract class _RepositoryAPI {
  static final Map<String, String> api = {
    'REPOSITORY_BASE_URI': '/repository',
    'REPOSITORY_GET_ID': '/get/id',
    'REPOSITORY_GET_QUERY': '/get/query',
    'REPOSITORY_LIST': '/list',
    'REPOSITORY_LIST_ALL_IDS': '/list/ids',
    'REPOSITORY_LIST_DISTINCT': '/list/distinct',
    'REPOSITORY_SAVE': '/save',
    'REPOSITORY_UPDATE': '/update',
    'REPOSITORY_ERASE': '/erase',
  };
}
