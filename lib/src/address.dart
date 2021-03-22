///
/// venosyd © 2016-2021
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.address;

import 'dart:async';
import 'dart:convert';

import 'package:opensyd_dart/opensyd_dart.dart';

import 'entities/_module_.dart';
import 'login.dart';
import 'repository.dart';
import 'util/_module_.dart';

///
/// @author sergio lisan
///
/// servidor de enderecos
///
class AddressProvider {
  ///
  AddressProvider({
    String host,
    bool devmode,
    bool securedev,
    RepositoryProvider repository,
    this.login,
  })  : _http = HttpProvider(host: host, api: _AddressAPI.api),
        entities = EntitiesRepository.build(
          login: login,
          devmode: devmode,
          securedev: securedev,
          repository: repository,
          db: DB,
          authkey: KEY,
          fromjson: OpensydModel.instance.instanceBuilder,
          emptyinstance: OpensydModel.instance.emptyInstanceGen,
          collectionmap: OpensydModel.instance.collectionMap,
        );

  ///
  factory AddressProvider.build(
    bool devmode,
    LoginProvider login, {
    bool securedev = false,
  }) =>
      AddressProvider(
        host: addressHost(devmode, securedev),
        devmode: devmode,
        securedev: securedev,
        login: login,
      );

  ///
  static const DB = '5956b256f5438105c4d2e242ea91e44b';

  ///
  static const KEY = 'b13af2c67189c10fe07bc5f5f90a'
      '4ec7423a8260dd84f015a0b73be5b9930287';

  ///
  final HttpProvider _http;

  ///
  final EntitiesRepository entities;

  ///
  final LoginProvider login;

  ///
  final Map<String, Logradouro> _cache = {};

  ///
  ///
  Future<Logradouro> getLogradouro(String cep) async {
    cep = (cep.startsWith('0') ? cep.substring(1) : cep).onlydigits;

    if (_cache.containsKey(cep)) {
      return _cache[cep];
    }

    final response = await _http.post([
      'ADDRESS_BASE_URI',
      'ADDRESS_GET_NEW_PLACE'
    ], <String, dynamic>{
      'cep': cep,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    if (response['status'] == 'ok') {
      final payload = response['payload'] as String;
      final jSON = json.decode(payload) as Map<String, dynamic>;

      final logradouro = Logradouro().fromJson(jSON);
      _cache[cep] = await logradouro.deep(entities);

      return logradouro;
    }

    return null;
  }

  ///
  Future<String> getMap(double latitude, double longitude) async {
    final payload = {
      'latitude': '$latitude',
      'longitude': '$longitude',
    };

    final response = await _http.post(
        [
          'ADDRESS_BASE_URI',
          'ADDRESS_GET_MAP',
        ],
        payload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    return response['status'] == 'ok' ? response['payload'] as String : '';
  }
}

///
/// API do Address
///
abstract class _AddressAPI {
  static final Map<String, String> api = {
    'ADDRESS_BASE_URI': '/address',
    'ADDRESS_GET_PLACE': '/get/place',
    'ADDRESS_GET_NEW_PLACE': '/get/new/place',
    'ADDRESS_GET_STATES': '/get/states',
    'ADDRESS_GET_CITIES': '/get/cities',
    'ADDRESS_GET_DISTRICTS': '/get/districts',
    'ADDRESS_UPDATE_PLACE': '/update/place',
    'ADDRESS_ADD_PLACE': '/add/place',
    'ADDRESS_GET_MAP': '/get/map',
  };
}
