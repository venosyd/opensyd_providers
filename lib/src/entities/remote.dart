///
/// venosyd © 2016-2021
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.entities.repository;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:opensyd_dart/opensyd_dart.dart';

import '../login.dart';
import '../repository.dart';
import '_module_.dart';

///
class RemoteEntitiesProvider extends EntitiesRepository {
  ///
  RemoteEntitiesProvider({
    @required this.mongodb,
    @required this.login,
    @required this.authkey,
    @required this.database,
    @required InstanceBuilder builder,
    @required CollectionMap collectionmap,
    @required EmptyInstanceGen emptyinstance,
    this.cachedisabled = false,
  }) : super(
          builder: builder,
          collectionmap: collectionmap,
          emptyinstance: emptyinstance,
        );

  ///
  final String authkey;

  ///
  final String database;

  ///
  final RepositoryProvider mongodb;

  ///
  final LoginProvider login;

  ///
  final bool cachedisabled;

  //
  // UTILS
  //

  ///
  void cleancache(Type type) {
    cache.remove(type);
    // mongodb.requests.clear();
  }

  //
  // PERSIST
  //

  @override
  Future<T> save<T extends OpensydEntity>(T object, [Type type]) async {
    final obj = object.id == null ? await _save(object) : await _update(object);

    if (obj != null && !cachedisabled) {
      if (!cache.containsKey(T)) {
        cache[T] = {};
      }

      cache[T][obj.id] = obj;
    }

    return obj;
  }

  ///
  Future<T> _save<T extends OpensydEntity>(T object) async {
    final response = await mongodb.save(
      authkey: authkey,
      token: await login.token,
      logindb: login.logindb,
      database: database,
      payload: object.json,
    );

    return response.isNotEmpty ? (builder(response) as T) : null;
  }

  ///
  Future<T> _update<T extends OpensydEntity>(T object) async {
    final response = await mongodb.update(
      authkey: authkey,
      token: await login.token,
      logindb: login.logindb,
      database: database,
      payload: object.json,
    );

    return response.isNotEmpty ? (builder(response) as T) : null;
  }

  @override
  Future<String> delete<T extends OpensydEntity>(T object,
      [Type type]) async {
    final result = await mongodb.erase(
      authkey: authkey,
      token: await login.token,
      logindb: login.logindb,
      database: database,
      payload: object.json,
    );

    cache[T]?.remove(object.id);

    return result;
  }

  //
  // / PERSIST
  //

  //
  // GETTER
  //

  @override
  Future<T> byID<T extends OpensydEntity>(String id, [Type type]) async {
    if (id == null || id.isEmpty) {
      return null;
    }

    if (cache.containsKey(T) && !cachedisabled) {
      final obj = cache[T][id] as T;
      if (obj != null) {
        return obj;
      }
    }

    final response = await mongodb.getByID(
      authkey: authkey,
      token: await login.token,
      logindb: login.logindb,
      database: database,
      collection: collectionmap(T),
      id: id,
    );

    final obj = response.isNotEmpty ? builder(response) as T : null;

    if (obj != null && !cachedisabled) {
      if (!cache.containsKey(T)) {
        cache[T] = {};
      }
      cache[T][obj.id] = obj;
    }

    return obj;
  }

  @override
  Future<T> by<T extends OpensydEntity>({
    String field,
    dynamic data,
    Type type,
  }) async {
    if ((field == null || field.isEmpty) || (data == null)) {
      return null;
    }

    if ((cache.containsKey(T)) && !cachedisabled) {
      final obj = cache[T]
          .values
          .firstWhere((e) => e.json[field] == data, orElse: () => null) as T;
      if (obj != null) {
        return obj;
      }
    }

    final response = await mongodb.getByQuery(
      authkey: authkey,
      token: await login.token,
      logindb: login.logindb,
      database: database,
      collection: collectionmap(T),
      query: <String, dynamic>{
        field: data,
      },
    );

    final obj = response.isNotEmpty ? (builder(response) as T) : null;

    if (obj != null && !cachedisabled) {
      if (!cache.containsKey(T)) {
        cache[T] = {};
      }
      cache[T][obj.id] = obj;
    }

    return obj;
  }

  @override
  Future<T> byQuery<T extends OpensydEntity>(Map<String, dynamic> query,
      [Type type]) async {
    if (query == null || query.isEmpty) {
      return null;
    }

    if (cache.containsKey(T) && !cachedisabled) {
      List<T> objs = [];

      Iterable<OpensydEntity> it = cache[T].values;

      query.forEach((field, dynamic data) =>
          it = it.where((e) => searchByQuery(e, query)));

      objs = it.toList().cast<T>();

      if (objs.isNotEmpty) {
        return objs[0];
      }
    }

    final response = await mongodb.getByQuery(
      authkey: authkey,
      token: await login.token,
      logindb: login.logindb,
      database: database,
      collection: collectionmap(T),
      query: query,
    );

    final obj = response.isNotEmpty ? (builder(response) as T) : null;

    if (obj != null && !cachedisabled) {
      if (!cache.containsKey(T)) {
        cache[T] = {};
      }
      cache[T][obj.id] = obj;
    }

    return obj;
  }

  //
  // / GETTER
  //

  //
  // LISTERS
  //

  @override
  Future<List<T>> all<T extends OpensydEntity>([Type type]) async {
    var list = <T>[];

    // with cache
    if (cache.containsKey(T) && !cachedisabled) {
      final cached = cache[T].values.toList().cast<T>();
      list = (await mongodb.list(
              authkey: authkey,
              token: await login.token,
              logindb: login.logindb,
              database: database,
              collection: collectionmap(T),
              query: notThisIDs(cached)))
          .map((e) => builder(e))
          .toList()
          .cast<T>();

      list.forEach((e) => cache[T][e.id] = e);
      list.addAll(cached);
    }

    // with no cache
    else {
      list = (await mongodb.list(
              authkey: authkey,
              token: await login.token,
              logindb: login.logindb,
              database: database,
              collection: collectionmap(T),
              query: <String, dynamic>{}))
          .map((e) => builder(e))
          .toList()
          .cast<T>();

      if (!cachedisabled) {
        if (!cache.containsKey(T)) {
          cache[T] = {};
        }
        list.forEach((e) => cache[T][e.id] = e);
      }
    }

    list.sort((i, j) => i.id.compareTo(j.id));
    return list;
  }

  @override
  Future<List<String>> allIDs<T extends OpensydEntity>([
    Map<String, dynamic> query,
    Type type,
  ]) async =>
      (await mongodb.listIDs(
        authkey: authkey,
        token: await login.token,
        logindb: login.logindb,
        database: database,
        collection: collectionmap(T),
        query: query ?? <String, dynamic>{},
      ))
          .map((e) => e['id'] as String)
          .toList();

  @override
  Stream<List<T>> allStream<T extends OpensydEntity>({
    Map<String, dynamic> query,
    List<String> ids,
    Type type,
  }) async* {
    const slicesize = 10;
    final elements = <T>[];

    ids = ids ?? await allIDs<T>(query);

    for (final slice in ids / slicesize) {
      elements.addAll(await listByIDs<T>(slice));
      yield elements;
    }
  }

  @override
  Future<List<T>> listByIDs<T extends OpensydEntity>(
    List<String> ids, [
    Type type,
  ]) async =>
      await listByQuery<T>(<String, dynamic>{
        '_id': {
          r'$in': ids,
        }
      });

  @override
  Future<List<T>> listBy<T extends OpensydEntity>({
    String field,
    dynamic data,
    Type type,
  }) async {
    if ((field == null || field.isEmpty) || (data == null)) {
      return [];
    }

    var list = <T>[];

    // with cache
    if (cache.containsKey(T) && !cachedisabled) {
      final cached = cache[T]
          .values
          .where((e) => e.json[field] == data)
          .toList()
          .cast<T>();

      list = (await mongodb.list(
              authkey: authkey,
              token: await login.token,
              logindb: login.logindb,
              database: database,
              collection: collectionmap(T),
              query: <String, dynamic>{
            r'$and': [
              <String, dynamic>{
                field: data,
              },
              notThisIDs(cached),
            ]
          }))
          .map((e) => builder(e))
          .toList()
          .cast<T>();

      list.forEach((e) => cache[T][e.id] = e);
      list.addAll(cached);
    }

    // with no cache
    else {
      list = (await mongodb.list(
              authkey: authkey,
              token: await login.token,
              logindb: login.logindb,
              database: database,
              collection: collectionmap(T),
              query: <String, dynamic>{
            field: data,
          }))
          .map((e) => builder(e))
          .toList()
          .cast<T>();

      if (!cachedisabled) {
        if (!cache.containsKey(T)) {
          cache[T] = {};
        }
        list.forEach((e) => cache[T][e.id] = e);
      }
    }

    list.sort((i, j) => i.id.compareTo(j.id));
    return list;
  }

  @override
  Future<List<T>> listByQuery<T extends OpensydEntity>(
    Map<String, dynamic> query, [
    Type type,
  ]) async {
    if (query == null || query.isEmpty) {
      return await all<T>(type);
    }

    var list = <T>[];

    // with cache
    if (cache.containsKey(T) && !cachedisabled) {
      Iterable<OpensydEntity> it = cache[T].values;

      query.forEach((field, dynamic data) =>
          it = it.where((e) => searchByQuery(e, query)));

      final cached = it.toList().cast<T>();

      list = (await mongodb.list(
        authkey: authkey,
        token: await login.token,
        logindb: login.logindb,
        database: database,
        collection: collectionmap(T),
        query: <String, dynamic>{
          r'$and': [query, notThisIDs(cached)]
        },
      ))
          .map((e) => builder(e))
          .toList()
          .cast<T>();

      list.forEach((e) => cache[T][e.id] = e);
      list.addAll(cached);
    }

    // with no cache
    else {
      list = (await mongodb.list(
        authkey: authkey,
        token: await login.token,
        logindb: login.logindb,
        database: database,
        collection: collectionmap(T),
        query: query,
      ))
          .map((e) => builder(e))
          .toList()
          .cast<T>();

      if (!cachedisabled) {
        if (!cache.containsKey(T)) {
          cache[T] = {};
        }
        list.forEach((e) => cache[T][e.id] = e);
      }
    }

    list.sort((i, j) => i.id.compareTo(j.id));
    return list;
  }

  //
  // / LISTERS
  //
}
