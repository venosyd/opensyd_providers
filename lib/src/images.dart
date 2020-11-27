///
/// venosyd © 2016-2020
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.images;

import 'dart:async';
import 'dart:convert';

import 'package:opensyd_dart/opensyd_dart.dart';

import 'login.dart';
import 'util/_module_.dart';

///
/// provedor de carregamento de imagens
///
class ImagesProvider {
  ///
  ImagesProvider(String host, this.cache, this.login)
      : _http = HttpProvider(
          host: host,
          api: _ImagesAPI.api,
        );

  ///
  factory ImagesProvider.build(
    bool devmode,
    Database database,
    LoginProvider login, {
    bool securedev = false,
  }) =>
      ImagesProvider(
        imagesHost(devmode, securedev),
        database,
        login,
      );

  ///
  static const String BLANK_IMAGE =
      'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==';

  ///
  final HttpProvider _http;

  ///
  final LoginProvider login;

  ///
  final Database cache;

  /// verifica a extensao da imagem
  static String extension(String chain) => chain.startsWith('iVBOR')
      ? '.png'
      : (chain.startsWith('/9') ? '.jpg' : '.gif');

  ///
  Future<String> save({
    String collection,
    String item,
    String image,
  }) async {
    final payload = {
      'hash': login.logindb,
      'collection': collection,
      'item': item,
      'file': image,
    };

    final response = await _http.post(
        [
          'IMAGES_BASE_URI',
          'IMAGES_SAVE',
        ],
        payload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    return response['status'] == 'ok' ? Responses.SUCCESS : Responses.FAILURE;
  }

  ///
  Future<String> load({String collection, String item}) async {
    final cached = await cache.retrieveImage('$collection/$item');
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final payload = {
      'hash': login.logindb,
      'collection': collection,
      'item': item,
    };

    final response = await _http.post(
        [
          'IMAGES_BASE_URI',
          'IMAGES_LOAD',
        ],
        payload,
        headers: {
          'Authorization':
              'Basic ${base64.encode((await login.token).codeUnits)}',
        });

    if (response['status'] == 'ok' &&
        (response['payload'] as String).isNotEmpty) {
      final image = response['payload'] as String;
      await cache.saveImage('$collection/$item', image);

      return image;
    }

    return BLANK_IMAGE;
  }
}

///
abstract class _ImagesAPI {
  static final Map<String, String> api = {
    'IMAGES_BASE_URI': '/images',
    'IMAGES_SAVE': '/save',
    'IMAGES_LOAD': '/load',
  };
}
